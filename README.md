# Bitcoin-Backed Stablecoin System

A decentralized stablecoin system implemented in Clarity that enables users to mint stablecoins using Bitcoin as collateral. The system maintains stability through overcollateralization and includes robust mechanisms for liquidation, debt management, and price oracle updates.

## Features

- Bitcoin collateralization with 150% minimum collateral ratio
- Automated liquidation system with 120% threshold
- Price oracle integration with freshness checks
- Collateral deposit and withdrawal mechanisms
- Stablecoin minting and burning
- Position management and health checks
- Comprehensive liquidation history tracking

## System Parameters

- Minimum Collateralization Ratio: 150%
- Liquidation Threshold: 120%
- Minimum Deposit: 1,000,000 satoshis
- Price Validity Period: 144 blocks (~1 day)

## Smart Contract Functions

### User Functions

#### `deposit-collateral (amount uint)`

Allows users to deposit Bitcoin as collateral.

- Requires amount to meet minimum deposit threshold
- Updates user's position with new collateral amount

#### `mint-stablecoin (amount uint)`

Enables users to mint stablecoins against their deposited collateral.

- Checks price oracle freshness
- Ensures sufficient collateralization ratio
- Updates total supply and user's debt position

#### `repay-stablecoin (amount uint)`

Allows users to repay their stablecoin debt.

- Verifies user has sufficient debt to repay
- Updates total supply and user's position
- Burns the repaid stablecoins

#### `withdraw-collateral (amount uint)`

Enables users to withdraw their excess collateral.

- Verifies sufficient collateral exists
- Ensures withdrawal maintains minimum collateralization ratio
- Updates user's position

### Administrative Functions

#### `set-price (new-price uint)`

Restricted to price oracle for updating the Bitcoin price.

- Updates current price
- Records last update timestamp

#### `set-price-oracle (new-oracle principal)`

Restricted to contract owner for updating the price oracle address.

- Updates price oracle principal

### Read-Only Functions

#### `get-position (user principal)`

Returns user's current position including:

- Collateral amount
- Debt amount
- Last update timestamp

#### `get-collateral-ratio (user principal)`

Calculates current collateralization ratio for a user's position.

#### `get-current-price`

Returns the current Bitcoin price from the oracle.

## Error Codes

- `ERR-NOT-AUTHORIZED (1000)`: Caller lacks required permissions
- `ERR-INSUFFICIENT-COLLATERAL (1001)`: Collateral ratio below minimum
- `ERR-BELOW-MINIMUM (1002)`: Deposit below minimum threshold
- `ERR-INVALID-AMOUNT (1003)`: Invalid transaction amount
- `ERR-POSITION-NOT-FOUND (1004)`: User position doesn't exist
- `ERR-ALREADY-LIQUIDATED (1005)`: Position already liquidated
- `ERR-HEALTHY-POSITION (1006)`: Position health above liquidation threshold
- `ERR-PRICE-EXPIRED (1007)`: Price oracle data too old

## Security Considerations

1. **Price Oracle**

   - Price updates are time-bounded
   - Only authorized oracle can update prices
   - Price freshness checks prevent stale data usage

2. **Collateralization**

   - Strict minimum collateral requirements
   - Automated health checks on all position modifications
   - Conservative liquidation threshold

3. **Access Control**
   - Administrative functions restricted to authorized principals
   - Clear separation between user and admin capabilities

## Implementation Notes

- Built using Clarity smart contract language
- Maintains state using maps and data variables
- Implements proper error handling and validation
- Uses block height for temporal mechanics

## Getting Started

1. Deploy the contract to a Stacks blockchain
2. Set up the initial price oracle
3. Users can begin depositing Bitcoin as collateral
4. Monitor position health and maintain proper collateralization

## Development and Testing

To work with this contract:

1. Set up a Clarity development environment
2. Deploy to testnet for initial testing
3. Verify all error conditions and edge cases
4. Test liquidation mechanisms with various price scenarios
5. Validate oracle integration and price update mechanisms

## Best Practices for Users

1. Maintain healthy collateralization ratios above 150%
2. Monitor Bitcoin price movements
3. Act quickly if positions approach liquidation threshold
4. Understand liquidation mechanisms and risks

## Governance and Upgrades

- Contract owner can update price oracle
- System parameters are defined as constants
- Any upgrades require new contract deployment
