
(defn next-row []
  (var xs @[1])
  (while true
    (yield xs)
    (set xs (let [s (array/push xs 0)]
              (map + s (reverse s))))))

(def pascal-rows (fiber/new next-row))

(loop [x :in (range 10)]
  (pp (resume pascal-rows)))
