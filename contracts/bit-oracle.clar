;; Title: BitOracle - Decentralized Bitcoin Price Prediction Markets
;;
;; Summary: A trustless prediction market protocol built on Stacks Layer 2
;; enabling users to stake STX tokens on Bitcoin price movements with
;; transparent, oracle-verified settlement mechanisms.
;;
;; Description: BitOracle creates time-bounded prediction markets where
;; participants can stake STX on whether Bitcoin's price will rise or fall
;; within specific timeframes. The protocol uses authorized oracles for
;; price resolution, implements proportional payout distribution among
;; winners, and charges minimal platform fees. Built for the Stacks
;; ecosystem to leverage Bitcoin's security while enabling DeFi innovation.
;;
;; Features:
;; - Decentralized price prediction markets
;; - Oracle-based Bitcoin price resolution  
;; - Proportional winning distribution
;; - Configurable market parameters
;; - Layer 2 scaling on Bitcoin via Stacks

;; CONSTANTS & ERROR HANDLING

;; Administrative Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))

;; Error Code Definitions
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-PREDICTION (err u102))
(define-constant ERR-MARKET-CLOSED (err u103))
(define-constant ERR-ALREADY-CLAIMED (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))
(define-constant ERR-INVALID-PARAMETER (err u106))

;; STATE VARIABLES

;; Platform Configuration
(define-data-var oracle-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-data-var minimum-stake uint u1000000) ;; 1 STX minimum stake
(define-data-var fee-percentage uint u2) ;; 2% platform fee
(define-data-var market-counter uint u0) ;; Global market ID counter

;; DATA STRUCTURES

;; Market Data Structure
;; Stores comprehensive market information including price points, stakes, and timing
(define-map markets
  uint
  {
    start-price: uint, ;; Initial Bitcoin price (in micro-units)
    end-price: uint, ;; Final Bitcoin price (set upon resolution)
    total-up-stake: uint, ;; Total STX staked on price increase
    total-down-stake: uint, ;; Total STX staked on price decrease
    start-block: uint, ;; Block height when market opens
    end-block: uint, ;; Block height when market closes
    resolved: bool, ;; Market resolution status
  }
)

;; User Prediction Tracking
;; Maps user predictions to specific markets with stake and claim status
(define-map user-predictions
  {
    market-id: uint,
    user: principal,
  }
  {
    prediction: (string-ascii 4), ;; "up" or "down"
    stake: uint, ;; Amount of STX staked
    claimed: bool, ;; Payout claim status
  }
)