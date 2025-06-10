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

;; CORE PUBLIC FUNCTIONS

;; Create New Prediction Market
;; Allows contract owner to establish new Bitcoin price prediction markets
(define-public (create-market
    (start-price uint)
    (start-block uint)
    (end-block uint)
  )
  (let ((market-id (var-get market-counter)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (> end-block start-block) ERR-INVALID-PARAMETER)
    (asserts! (> start-price u0) ERR-INVALID-PARAMETER)
    (map-set markets market-id {
      start-price: start-price,
      end-price: u0,
      total-up-stake: u0,
      total-down-stake: u0,
      start-block: start-block,
      end-block: end-block,
      resolved: false,
    })
    (var-set market-counter (+ market-id u1))
    (ok market-id)
  )
)

;; Place Prediction Stake
;; Enables users to stake STX tokens on Bitcoin price direction
(define-public (make-prediction
    (market-id uint)
    (prediction (string-ascii 4))
    (stake uint)
  )
  (let (
      (market (unwrap! (map-get? markets market-id) ERR-NOT-FOUND))
      (current-block stacks-block-height)
    )
    ;; Validate market timing
    (asserts!
      (and
        (>= current-block (get start-block market))
        (< current-block (get end-block market))
      )
      ERR-MARKET-CLOSED
    )
    ;; Validate prediction parameters
    (asserts! (or (is-eq prediction "up") (is-eq prediction "down"))
      ERR-INVALID-PREDICTION
    )
    (asserts! (>= stake (var-get minimum-stake)) ERR-INVALID-PREDICTION)
    (asserts! (<= stake (stx-get-balance tx-sender)) ERR-INSUFFICIENT-BALANCE)
    ;; Transfer stake to contract
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
    ;; Record user prediction
    (map-set user-predictions {
      market-id: market-id,
      user: tx-sender,
    } {
      prediction: prediction,
      stake: stake,
      claimed: false,
    })
    ;; Update market totals
    (map-set markets market-id
      (merge market {
        total-up-stake: (if (is-eq prediction "up")
          (+ (get total-up-stake market) stake)
          (get total-up-stake market)
        ),
        total-down-stake: (if (is-eq prediction "down")
          (+ (get total-down-stake market) stake)
          (get total-down-stake market)
        ),
      })
    )
    (ok true)
  )
)