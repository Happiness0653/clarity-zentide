;; ZenTide Token Contract

(define-fungible-token zen-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))

;; Public functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (ft-mint? zen-token amount recipient)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (<= amount (ft-get-balance zen-token tx-sender)) err-insufficient-balance)
    (ft-transfer? zen-token amount tx-sender recipient)
  )
)

(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (<= amount (ft-get-balance zen-token tx-sender)) err-insufficient-balance)
    (ft-burn? zen-token amount tx-sender)
  )
)

;; Read only functions
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance zen-token account))
)
