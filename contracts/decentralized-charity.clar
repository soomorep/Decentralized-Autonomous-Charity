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


