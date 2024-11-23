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