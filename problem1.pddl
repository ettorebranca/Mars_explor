(define (problem mars_exploration_problem1)
  (:domain mars_exploration)
  (:objects 
    rover1 - rover
    drone1 - drone
    base1 - base
    loc1 - unknown_area
    res1 - resource
    rocks - obstacle 
  )
  (:init
    ;; Initial positions
    (at rover1 base1)
    (at drone1 base1)
    ;; Assume base is known and safe
    (scanned base1)
    (traversable base1)
    (explored base1)
    ;; Adjacency relationships (assume bidirectional travel)
    (adjacent base1 loc1)
    (adjacent loc1 base1)
    ;; Charging station available at the base
    (charging_station base1)
    ;; Energy levels
    (= (energy-level rover1) 0)
    (= (energy-level drone1) 0)
    ;; Resource location
    (resource_at res1 loc1)
    ;; Total cost counter initialization
    (= (total-cost) 0)
  )
  (:goal (and
         (collected res1)
         (at rover1 base1)
         (at drone1 base1)
))
  (:metric minimize (total-cost))
)