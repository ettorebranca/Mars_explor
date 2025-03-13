(define (problem mars_exploration_problem2)
  (:domain mars_exploration)
  (:objects 
    rover1 - rover
    drone1 - drone
    base1 - base
    loc1 loc2 loc3 loc4 - unknown_area
    res1 res2 - resource
    rocks pit - obstacle
  )
  (:init
    ;; Initial positions
    (at rover1 base1)
    (at drone1 base1)
    ;; Assume base is known and safe
    (scanned base1)
    (traversable base1)
    (explored base1)
    ;; Define adjacency (bidirectional)
    (adjacent base1 loc1)
    (adjacent loc1 base1)
    (adjacent base1 loc2)
    (adjacent loc2 base1)
    (adjacent loc3 base1)
    (adjacent base1 loc3)
    (adjacent loc4 base1)
    (adjacent base1 loc4)
    (adjacent loc1 loc2)
    (adjacent loc2 loc1)
    (adjacent loc1 loc3)
    (adjacent loc3 loc1)
    (adjacent loc4 loc2)
    (adjacent loc2 loc4)
    (adjacent loc4 loc3)
    (adjacent loc3 loc4)
    ;; Charging station
    (charging_station base1)
    ;; Energy levels
    (= (energy-level rover1) 0)
    (= (energy-level drone1) 0)
    ;; Resource location
    (resource_at res1 loc1)
    (resource_at res2 loc4)
    ;; Obstacle location
    (obstacle_at rocks loc2)
    (obstacle_at pit loc3)
    ;; Total cost counter initialization
    (= (total-cost) 0)
  )
  (:goal (and
         (collected res1)
         (collected res2)
         (at rover1 base1)
         (at drone1 base1)
))
  (:metric minimize (total-cost))
)