(use joy)

(defn home [request]
    (let [name (get-in request [:params :name])]
        (default name "Valued User")
        (text/plain (string "Greetings, " name))))


(defroutes app-routes
    [:get "/" home :get-no-name]
    [:get "/:name" home :get-with-name])

(def home-handler (-> app-routes handler logger))

(server home-handler 8002 "banting")