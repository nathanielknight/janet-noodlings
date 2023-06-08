# Generate fibonnaci numbers using a co-routine

(defn fibs []
  (var a 1)
  (var b 1)
  (while true
    (yield a)
    (let [x a
          y b]
      (set a y)
      (set b (+ x y)))))

(def f (fiber/new fibs))

(loop [x :in (range 32)]
  (print (resume f)))


