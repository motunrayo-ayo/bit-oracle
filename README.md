# BitOracle - Decentralized Bitcoin Price Prediction Markets

> A trustless prediction market protocol built on Stacks Layer 2, enabling users to stake STX tokens on Bitcoin price movements with transparent, oracle-verified settlement mechanisms.

## Overview

BitOracle creates time-bounded prediction markets where participants can stake STX on whether Bitcoin's price will rise or fall within specific timeframes. The protocol leverages Stacks' Layer 2 infrastructure to provide Bitcoin-secured DeFi functionality with minimal fees and fast settlement.

## Key Features

- **Decentralized Prediction Markets**: Create and participate in Bitcoin price prediction markets
- **Oracle-Based Resolution**: Secure price feeds from authorized oracles for fair settlement
- **Proportional Payouts**: Winners receive proportional shares based on their stake
- **Configurable Parameters**: Flexible market duration, minimum stakes, and fee structures
- **Bitcoin Security**: Built on Stacks Layer 2 for Bitcoin-level security guarantees
- **Low Fees**: Minimal platform fees (2% default) with transparent fee distribution

## System Architecture

### Core Components

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Market Owner  │    │    Participants  │    │   Price Oracle  │
│                 │    │                  │    │                 │
│ • Create Markets│    │ • Make Predictions│    │ • Price Updates │
│ • Set Parameters│    │ • Claim Winnings │    │ • Market Resolution│
│ • Withdraw Fees │    │ • View Markets   │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                         ┌─────────────────┐
                         │   BitOracle     │
                         │   Smart Contract│
                         │                 │
                         │ • Market Logic  │
                         │ • Stake Management│
                         │ • Payout Distribution│
                         └─────────────────┘
                                  │
                         ┌─────────────────┐
                         │   Stacks L2     │
                         │                 │
                         │ • STX Transfers │
                         │ • State Storage │
                         │ • Block Heights │
                         └─────────────────┘
                                  │
                         ┌─────────────────┐
                         │   Bitcoin L1    │
                         │                 │
                         │ • Security      │
                         │ • Finality      │
                         └─────────────────┘
```

### Contract Architecture

The BitOracle smart contract is structured around three primary data structures:

#### 1. Markets Map

```clarity
markets: {
  market-id → {
    start-price: uint,      // Initial Bitcoin price
    end-price: uint,        // Final Bitcoin price (post-resolution)
    total-up-stake: uint,   // Total STX staked on price increase
    total-down-stake: uint, // Total STX staked on price decrease
    start-block: uint,      // Market opening block
    end-block: uint,        // Market closing block
    resolved: bool          // Resolution status
  }
}
```

#### 2. User Predictions Map

```clarity
user-predictions: {
  (market-id, user) → {
    prediction: string,     // "up" or "down"
    stake: uint,           // STX amount staked
    claimed: bool          // Payout claim status
  }
}
```

#### 3. Configuration Variables

- `oracle-address`: Authorized price oracle principal
- `minimum-stake`: Minimum STX required for predictions (1 STX default)
- `fee-percentage`: Platform fee percentage (2% default)
- `market-counter`: Global market ID incrementer

## Data Flow

### Market Creation Flow

```
Owner → create-market() → Market Storage → Market ID Assignment
```

### Prediction Flow

```
User → make-prediction() → Validate Market → Transfer STX → Record Prediction → Update Totals
```

### Resolution Flow

```
Oracle → resolve-market() → Validate Authority → Set End Price → Mark Resolved
```

### Payout Flow

```
Winner → claim-winnings() → Calculate Share → Deduct Fees → Transfer Payout → Mark Claimed
```

## Core Functions

### Public Functions

| Function | Description | Access |
|----------|-------------|--------|
| `create-market` | Creates new prediction market | Owner Only |
| `make-prediction` | Stakes STX on price direction | Public |
| `resolve-market` | Sets final price and resolves market | Oracle Only |
| `claim-winnings` | Claims proportional winnings | Winners Only |

### Administrative Functions

| Function | Description | Access |
|----------|-------------|--------|
| `set-oracle-address` | Updates authorized oracle | Owner Only |
| `set-minimum-stake` | Updates minimum stake requirement | Owner Only |
| `set-fee-percentage` | Updates platform fee percentage | Owner Only |
| `withdraw-fees` | Withdraws accumulated platform fees | Owner Only |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-market` | Retrieves market information |
| `get-user-prediction` | Gets user's prediction details |
| `get-contract-balance` | Returns contract STX balance |

## Usage Examples

### Creating a Market

```clarity
;; Create a 24-hour Bitcoin price prediction market
(contract-call? .bitoracle create-market 
  u50000000000  ;; Start price: $50,000 (in micro-units)
  u1000         ;; Start block
  u1144         ;; End block (144 blocks ≈ 24 hours)
)
```

### Making a Prediction

```clarity
;; Stake 5 STX on Bitcoin price going up
(contract-call? .bitoracle make-prediction
  u0            ;; Market ID
  "up"          ;; Prediction direction
  u5000000      ;; Stake amount (5 STX in micro-STX)
)
```

### Claiming Winnings

```clarity
;; Claim winnings from market 0
(contract-call? .bitoracle claim-winnings u0)
```

## Security Considerations

- **Oracle Trust**: The system relies on authorized oracles for price data
- **Market Timing**: Markets use block heights for precise timing control
- **Stake Protection**: STX tokens are held in contract until resolution
- **Payout Verification**: Winners must manually claim to prevent automatic distributions
- **Fee Transparency**: All fees are calculated and distributed transparently

## Economic Model

### Payout Calculation

```
Total Pool = Total Up Stakes + Total Down Stakes
Winner Share = (User Stake / Winning Side Total) × Total Pool
Platform Fee = Winner Share × Fee Percentage
User Payout = Winner Share - Platform Fee
```

### Fee Structure

- **Platform Fee**: 2% of winnings (configurable)
- **Minimum Stake**: 1 STX (configurable)
- **No Entry Fees**: Users only pay on winnings

## Development Setup

### Prerequisites

- Clarinet CLI
- Stacks wallet for testing
- Node.js (for frontend integration)

### Contract Deployment

```bash
# Test the contract
clarinet test

# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

## Integration

### Frontend Integration

The contract provides read-only functions for frontend applications to:

- Display active markets
- Show user predictions and stakes
- Calculate potential payouts
- Track market resolution status

### Oracle Integration

Oracles must call `resolve-market` with accurate Bitcoin price data at market expiration.

## Roadmap

- [ ] Multi-asset prediction markets
- [ ] Automated market makers (AMM) integration
- [ ] Governance token for protocol decisions
- [ ] Advanced market types (ranges, multiple outcomes)
- [ ] Cross-chain oracle integration

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.
