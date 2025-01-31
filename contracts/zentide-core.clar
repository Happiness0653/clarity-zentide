;; ZenTide Core Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Data vars
(define-map users principal 
  {
    streaks: uint,
    total-sessions: uint,
    last-session: uint,
    achievements: (list 10 uint)
  }
)

(define-map achievements uint 
  {
    name: (string-ascii 50),
    description: (string-ascii 100),
    points: uint
  }
)

;; Public functions
(define-public (register-user)
  (begin
    (asserts! (is-none (map-get? users tx-sender)) err-already-exists)
    (ok (map-set users tx-sender {
      streaks: u0,
      total-sessions: u0, 
      last-session: u0,
      achievements: (list)
    }))
  )
)

(define-public (log-session)
  (let (
    (user (unwrap! (map-get? users tx-sender) err-not-found))
    (current-time block-height)
  )
    (ok (map-set users tx-sender 
      (merge user {
        total-sessions: (+ (get total-sessions user) u1),
        last-session: current-time
      })
    ))
  )
)

;; Read only functions  
(define-read-only (get-user-stats (user principal))
  (ok (map-get? users user))
)
