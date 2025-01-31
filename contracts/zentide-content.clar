;; ZenTide Content Contract

;; Constants  
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-instructor (err u101))

;; Data vars
(define-map instructors principal bool)

(define-map content uint 
  {
    instructor: principal,
    title: (string-ascii 50),
    content-type: (string-ascii 20),
    duration: uint,
    created-at: uint
  }
)

(define-data-var content-counter uint u0)

;; Public functions
(define-public (add-instructor (instructor principal))
  (begin 
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set instructors instructor true))
  )
)

(define-public (publish-content (title (string-ascii 50)) (content-type (string-ascii 20)) (duration uint))
  (let ((counter (var-get content-counter)))
    (asserts! (default-to false (map-get? instructors tx-sender)) err-not-instructor)
    (map-set content counter
      {
        instructor: tx-sender,
        title: title,
        content-type: content-type,
        duration: duration,
        created-at: block-height
      }
    )
    (var-set content-counter (+ counter u1))
    (ok counter)
  )
)
