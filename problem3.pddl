(define (problem mars_exploration_problem3)
  (:domain mars_exploration)
  (:objects 
    rover1 rover2 - rover
    drone1 drone2 - drone
    base1 - base
    loc1 loc2 loc3 loc4 loc5 loc6 loc7 loc8 - unknown_area
    res1 res2 res3 res4 res5 - resource
    rocks pit - obstacle
  )
  (:init
    ;; Initial positions
    (at rover1 base1)
    (at drone1 base1)
    (at rover2 base1)
    (at drone2 base1)
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
    (adjacent loc1 loc5)
    (adjacent loc5 loc1)
    (adjacent loc1 loc6)
    (adjacent loc6 loc1)
    (adjacent loc5 loc6)
    (adjacent loc6 loc5)
    (adjacent loc4 loc7)
    (adjacent loc7 loc4)
    (adjacent loc7 loc8)
    (adjacent loc8 loc7)
    ;; Charging station
    (charging_station base1)
    ;; Energy levels
    (= (energy-level rover1) 0)
    (= (energy-level drone1) 0)
    (= (energy-level rover2) 0)
    (= (energy-level drone2) 0)
    ;; Resource location
    (resource_at res1 loc1)
    (resource_at res2 loc4)
    (resource_at res3 loc6)
    (resource_at res4 loc8)
    (resource_at res5 loc8)
    ;; Obstacle location
    (obstacle_at rocks loc2)
    (obstacle_at pit loc3)
    ;; Inizializzazione dei contatori
    (= (total-cost) 0)
  )
  (:goal (and
         (collected res5)
         (collected res4)
         (collected res3)
         (collected res2)
         (collected res1)
         (at rover1 base1)
         (at drone1 base1)
         (at rover2 base1)
         (at drone2 base1)
))
  (:metric minimize (total-cost))
)