(defn choose [n k]
  (product
    (seq [i :in (range 1 (+ k 1))]
      (/ (+ n 1 (- i)) i))))

      
    
