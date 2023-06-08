

(def ROWS 20)
(def COLUMNS 88)

(let [urandom (file/open "/dev/urandom" :rb)]
  (math/seedrandom (file/read urandom 16)))


(defn print-maze []
    (def RNG (math/rng (os/time)))
    (defn char []
        (if (> (math/rng-uniform RNG) 0.5) "╱" "╲"))
    (loop [r :in (range ROWS)]
        (loop [c :in (range COLUMNS)]
            (prin (char)))
        (prin "\n")))

(while true
    (printf "\x1Bc")
    (print-maze)
    (ev/sleep 0.1))
