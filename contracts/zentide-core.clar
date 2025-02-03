;; ZenTide Core Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101)) 
(define-constant err-already-exists (err u102))
(define-constant STREAK_THRESHOLD u86400) ;; 24 hours in blocks (assuming 1 block/sec)

;; Data vars
(define-map users principal 
  {
    streaks: uint,
    total-sessions: uint,
    last-session: uint,
    achievements: (list 10 uint),
    current-streak: uint
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
      achievements: (list),
      current-streak: u0
    }))
  )
)

(define-public (log-session)
  (let (
    (user (unwrap! (map-get? users tx-sender) err-not-found))
    (current-time block-height)
    (last-session (get last-session user))
    (current-streak (get current-streak user))
    (streaks (get streaks user))
    (new-streak (if (< (- current-time last-session) STREAK_THRESHOLD)
      (+ current-streak u1)
      u1))
  )
    (ok (map-set users tx-sender 
      (merge user {
        total-sessions: (+ (get total-sessions user) u1),
        last-session: current-time,
        current-streak: new-streak,
        streaks: (if (> new-streak streaks) new-streak streaks)
      })
    ))
  )
)

;; Read only functions  
(define-read-only (get-user-stats (user principal))
  (ok (map-get? users user))
)
