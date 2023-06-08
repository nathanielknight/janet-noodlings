# Generate an image in the style of Piet Mondrian, printing the result as an
# SVG.
(import spork/htmlgen)
(import spork/http)


(let [urandom (file/open "/dev/urandom" :rb)]
  (math/seedrandom (file/read urandom 16)))


(defn randint [n]
  (-> (math/random)
      (* n)
      (math/floor)))

(defn choose [xs]
  (in xs (randint (length xs))))

(def COLORS {
  :white 10
  :red 1
  :blue 1
  :yellow 1
  :black 1
  :gray 1
})

(defn to-count-array [freqs]
  (apply array/concat
    (seq [[v n] :pairs freqs]
      (array/new-filled n v))))

(def CHOOSECOLOR (to-count-array COLORS))

(defn random-color []
  (choose CHOOSECOLOR))

(defn norm-pdf [x m s]
  (defn square [x] (* x x))
  (defn inv [x] (/ 1 x))
  (let [
    coeff (* s (math/sqrt (* 2 math/pi)))
    expart (* -0.5 (square (* (- x m) (inv s))))
  ]
    (* (inv coeff) (math/exp expart))))

# (defn split-interval [a]
#   (let [x (* a (math/random))
#         y (norm-pdf x (/ a 2) (/ a 6))]
#     (if (< (math/random) y)
#       x
#       (split-interval a))))

(defn split-interval [a]
  (/ a 2))

(defn split-horizontal [{:x x :y y :w w :h h}]
  (def split-at (split-interval w))
  [
    {:x x :y y :w split-at :h h :c (random-color)}
    {:x (+ x split-at) :y y :w (- w split-at) :h h :c (random-color)}
  ])

(defn split-vertical [{:x x :y y :w w :h h}]
  (def split-at (split-interval h))
  [
    {:x x :y y :w w :h split-at :c (random-color)}
    {:x x :y (+ y split-at) :w w :h (- h split-at) :c (random-color)}
  ])

(def SPLITTERS {
 :horizontal split-horizontal
 :vertical split-vertical
})

(defn split [r split-direction]
  ((SPLITTERS split-direction) r))

(defn next-split-direction [d]
  ({:horizontal :vertical :vertical :horizontal} d))

(def MAXLVL 8)
(def MINLVL 4)

(defn stop-splitting? [lvl]
  (cond
    (>= lvl MAXLVL) true
    (< lvl MINLVL) false
    (< (math/random) (/ lvl MAXLVL))))

(defn gen-mondrian [r lvl split-direction]
  (if (stop-splitting? lvl)
    @[r]
    (apply array/concat
      (seq [r :in (split r split-direction)]
        (gen-mondrian r (+ lvl 1) (next-split-direction split-direction))))))


(defn rect [x y w h] {:x x :y y :w w :h h :c :white})

(defn mondrian [&opt r]
  (default r (rect 0 0 10 10))
  (gen-mondrian r 0 :vertical))

(defn svg-rect [{:x x :y y :w w :h h :c c}]
  (defn pct [x] (string (* 10 x) "%"))
  ['rect {:x (pct x) :y (pct y) :width (pct w) :height (pct h) :fill c :style "strokewidth:99;stroke:rgb(0,0,0)"}])

(defn as-svg [rects]
  (htmlgen/html
    [:html
      [:body
        [:svg
	  {:width "640px" :height "400px" :viewbox "0 0 10 10" :version "1.1" :xmlns "http://www.w3.org/2000/svg" :xmlns:xlink "http://www.w3.org/1999/xlink"}
          (map svg-rect rects)]]]))

(defn handler [_]
  {:status 200
   :headers {"content-type" "image/svg+xml"}
   :body (as-svg (mondrian))})

(http/server handler)
