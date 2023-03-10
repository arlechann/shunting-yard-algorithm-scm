(define (flatten ls)
  (define (rec ls acc)
    (cond ((null? ls) acc)
          ((list? (car ls)) (rec (cdr ls) (rec (car ls) acc)))
          (else (rec (cdr ls) (cons (car ls) acc)))))
  (reverse! (rec ls '())))

(define (calc form)
  (define (init-stack) '())
  (define stack-empty? null?)
  (define (push obj stack) (cons obj stack))
  (define (top stack) (if (null? stack) '() (car stack)))
  (define (pop stack) (if (null? stack) '() (cdr stack)))

  (define (calculate-rev-polish form)
    (define (top-2 stack)
      (list (top stack) (top (pop stack))))
    (define (pop-2 stack)
      (pop (pop stack)))

    (define (pop-calculate proc form stack)
      (calculate (cdr form) (push (apply proc (reverse! (top-2 stack))) (pop-2 stack))))
    (define (calculate form stack)
      (cond ((null? form) (car stack))
            ((number? (car form)) (calculate (cdr form) (push (car form) stack)))
            ((symbol=? (car form) '+) (pop-calculate + form stack))
            ((symbol=? (car form) '-) (pop-calculate - form stack))
            ((symbol=? (car form) '*) (pop-calculate * form stack))
            ((symbol=? (car form) '/) (pop-calculate / form stack))
            (error)))

    (calculate form (init-stack)))

  (define (infix->rev-polish form)
    (define (priority token)
      (cond ((or (eq? token '*) (eq? token '/)) 2)
            ((or (eq? token '+) (eq? token '-)) 1)
            (else -1)))
    (define (prior? token1 token2)
      (> (priority token1) (priority token2)))

    (define (rec form stack converted)
      (cond ((and (null? form) (stack-empty? stack)) converted)
            ((null? form) (rec '() (pop stack) (cons (top stack) converted)))
            ((list? (car form)) (rec (cdr form) stack (cons (rec (car form) (init-stack) '()) converted)))
            ((symbol? (car form))
              (if (prior? (car form) (top stack))
                  (rec (cdr form) (push (car form) stack) converted)
                  (rec form (pop stack) (cons (top stack) converted))))
            (else (rec (cdr form) stack (cons (car form) converted)))))
    (reverse! (flatten (rec form (init-stack) '()))))

  (calculate-rev-polish (infix->rev-polish form)))
