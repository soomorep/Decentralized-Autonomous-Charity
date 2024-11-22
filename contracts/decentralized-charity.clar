;; Decentralized Autonomous Charity

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-proposal-active (err u104))
(define-constant err-proposal-ended (err u105))
(define-constant err-already-voted (err u106))

;; Data Maps
(define-map donors
  { donor: principal }
  { total-donated: uint, voting-power: uint }
)

(define-map proposals
  { proposal-id: uint }
  {
    beneficiary: principal,
    amount: uint,
    description: (string-utf8 500),
    votes-for: uint,
    votes-against: uint,
    is-active: bool,
    is-executed: bool,
    end-block: uint
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { amount: uint }
)

;; Variables
(define-data-var last-proposal-id uint u0)
(define-data-var charity-balance uint u0)

;; Private Functions
(define-private (is-owner)
  (is-eq tx-sender contract-owner)
)

;; Public Functions
(define-public (donate)
  (let
    (
      (donation-amount (stx-get-balance tx-sender))
      (donor-info (default-to { total-donated: u0, voting-power: u0 } (map-get? donors { donor: tx-sender })))
    )
    (try! (stx-transfer? donation-amount tx-sender (as-contract tx-sender)))
    (var-set charity-balance (+ (var-get charity-balance) donation-amount))
    (ok (map-set donors { donor: tx-sender }
      {
        total-donated: (+ (get total-donated donor-info) donation-amount),
        voting-power: (+ (get voting-power donor-info) donation-amount)
      }))
  )
)

(define-public (create-proposal (beneficiary principal) (amount uint) (description (string-utf8 500)) (duration uint))
  (let
    (
      (new-proposal-id (+ (var-get last-proposal-id) u1))
      (end-block (+ block-height duration))
    )
    (asserts! (>= (var-get charity-balance) amount) err-insufficient-funds)
    (map-set proposals { proposal-id: new-proposal-id }
      {
        beneficiary: beneficiary,
        amount: amount,
        description: description,
        votes-for: u0,
        votes-against: u0,
        is-active: true,
        is-executed: false,
        end-block: end-block
      }
    )
    (var-set last-proposal-id new-proposal-id)
    (ok new-proposal-id)
  )
)
