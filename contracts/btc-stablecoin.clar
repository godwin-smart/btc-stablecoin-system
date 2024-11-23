;; title: Bitcoin-Backed Stablecoin System
;; summary: A decentralized stablecoin system backed by Bitcoin with overcollateralization.
;; description: This smart contract implements a robust stablecoin system where users can deposit Bitcoin as collateral to mint stablecoins. The system ensures stability through overcollateralization and includes mechanisms for liquidation, collateral withdrawal, and debt repayment. It also features administrative functions for setting the Bitcoin price and managing the price oracle.

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u1001))
(define-constant ERR-BELOW-MINIMUM (err u1002))
(define-constant ERR-INVALID-AMOUNT (err u1003))
(define-constant ERR-POSITION-NOT-FOUND (err u1004))
(define-constant ERR-ALREADY-LIQUIDATED (err u1005))
(define-constant ERR-HEALTHY-POSITION (err u1006))
(define-constant ERR-PRICE-EXPIRED (err u1007))

;; Define minimum collateralization ratio (150%)
(define-constant MIN-COLLATERAL-RATIO u150)
;; Liquidation threshold (120%)
(define-constant LIQUIDATION-RATIO u120)
;; Minimum deposit amount (satoshis)
(define-constant MIN-DEPOSIT u1000000)
;; Price validity period (144 blocks ~ 1 day)
(define-constant PRICE-VALIDITY-PERIOD u144)

;; Data Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var price-oracle principal tx-sender)
(define-data-var total-supply uint u0)
(define-data-var btc-price uint u0)
(define-data-var last-price-update uint block-height)

;; Data Maps
(define-map user-positions
    principal
    {
        collateral: uint,
        debt: uint,
        last-update: uint
    }
)

(define-map liquidation-history
    principal
    {
        timestamp: uint,
        collateral-liquidated: uint,
        debt-repaid: uint
    }
)

;; Read-only functions
(define-read-only (get-position (user principal))
    (map-get? user-positions user)
)

(define-read-only (get-collateral-ratio (user principal))
    (let (
        (position (unwrap! (get-position user) (err u0)))
        (collateral-value (* (get collateral position) (var-get btc-price)))
        (debt-value (* (get debt position) u100000000))
    )
        (if (is-eq (get debt position) u0)
            (ok u0)
            (ok (/ (* collateral-value u100) debt-value)))
    )
)

(define-read-only (get-current-price)
    (ok (var-get btc-price))
)

;; Private functions
(define-private (check-price-freshness)
    (if (< (- block-height (var-get last-price-update)) PRICE-VALIDITY-PERIOD)
        (ok true)
        ERR-PRICE-EXPIRED
    )
)

(define-private (check-min-collateral (amount uint))
    (if (>= amount MIN-DEPOSIT)
        (ok true)
        ERR-BELOW-MINIMUM
    )
)

(define-private (check-position-health (user principal))
    (let (
        (ratio (unwrap! (get-collateral-ratio user) (err u0)))
    )
        (if (< ratio MIN-COLLATERAL-RATIO)
            ERR-INSUFFICIENT-COLLATERAL
            (ok true))
    )
)

;; Public functions
(define-public (deposit-collateral (amount uint))
    (begin
        (try! (check-min-collateral amount))
        (let (
            (current-position (default-to 
                { collateral: u0, debt: u0, last-update: block-height }
                (get-position tx-sender)
            ))
        )
            (map-set user-positions tx-sender
                {
                    collateral: (+ amount (get collateral current-position)),
                    debt: (get debt current-position),
                    last-update: block-height
                }
            )
            (ok true))
    )
)

(define-public (mint-stablecoin (amount uint))
    (begin
        (try! (check-price-freshness))
        (let (
            (current-position (unwrap! (get-position tx-sender) ERR-POSITION-NOT-FOUND))
            (new-debt (+ amount (get debt current-position)))
            (collateral-value (* (get collateral current-position) (var-get btc-price)))
            (required-collateral (* new-debt MIN-COLLATERAL-RATIO))
        )
            (asserts! (>= collateral-value required-collateral) ERR-INSUFFICIENT-COLLATERAL)
            
            (map-set user-positions tx-sender
                {
                    collateral: (get collateral current-position),
                    debt: new-debt,
                    last-update: block-height
                }
            )
            (var-set total-supply (+ (var-get total-supply) amount))
            (ok true))
    )
)

(define-public (repay-stablecoin (amount uint))
    (let (
        (current-position (unwrap! (get-position tx-sender) ERR-POSITION-NOT-FOUND))
    )
        (asserts! (>= (get debt current-position) amount) ERR-INVALID-AMOUNT)
        
        (map-set user-positions tx-sender
            {
                collateral: (get collateral current-position),
                debt: (- (get debt current-position) amount),
                last-update: block-height
            }
        )
        (var-set total-supply (- (var-get total-supply) amount))
        (ok true)
    )
)