(define (domain mars_exploration)
    (:requirements :strips :typing :adl :action-costs :existential-preconditions :conditional-effects)
    (:types
        agent location obstacle resource - object
        rover drone - agent
        base unknown_area - location
    )

    (:predicates
        (at ?agent - agent ?loc - location)
        (adjacent ?from ?to - location)
        (scanned ?loc - location)
        (traversable ?loc - location)
        (obstacle_at ?obst - obstacle ?loc - location)
        (explored ?loc - location)
        (resource_at ?res - resource ?loc - location)
        (collected ?res)
        (charging_station ?loc - location)
    )

    (:functions (energy-level ?agent - agent)
                (total-cost)
    )

    ;; Fly action (for drones) between adjacent locations
    (:action fly
        :parameters (?drone - drone ?from - location ?to - location)
        :precondition (and (at ?drone ?from)
                           (adjacent ?from ?to)
                           (> (energy-level ?drone) 0))
        :effect (and (at ?drone ?to)
                     (not (at ?drone ?from))
                     (decrease (energy-level ?drone) 1)
                     (increase (total-cost) 1))
    )

    ;; Scan action (drone scans a location to allow the rover to explore it avoiding collisions with obstacles)
    (:action scan
        :parameters (?drone - drone ?loc - location)
        :precondition (and (at ?drone ?loc)
                     (not (scanned ?loc)))
        :effect (and
                (scanned ?loc)
                (increase (total-cost) 1)
                ;; If no obstacles are present at the location, mark it as traversable.
                (when (not (exists (?obs - obstacle) (obstacle_at ?obs ?loc)))
                  (traversable ?loc))
                ;; If there is an obstacle, ensure the location is not marked traversable.
                (when (exists (?obs - obstacle) (obstacle_at ?obs ?loc))
                  (not (traversable ?loc)))
              )
    )

    ;; Move action (for rovers) between adjacent and traversable locations
    (:action move
        :parameters (?rover - rover ?from - location ?to - location)
        :precondition (and  (at ?rover ?from)
                            (adjacent ?from ?to)
                            (scanned ?to)
                            (traversable ?to) 
                            (> (energy-level ?rover) 0))
        :effect (and (at ?rover ?to)
                     (not (at ?rover ?from))
                     (decrease (energy-level ?rover) 1)
                     (increase (total-cost) 1))
    )

    ;; Explore action (rover explores a location)
    (:action explore
        :parameters (?rover - rover ?loc - location)
        :precondition (and  (at ?rover ?loc) 
                            (not (explored ?loc))
                            (> (energy-level ?rover) 1))
        :effect (and 
             (explored ?loc)
             (decrease (energy-level ?rover) 2)
             (increase (total-cost) 2)
                )
    )

    ;; Collect resource action 
    (:action collect
        :parameters (?rover - rover ?res - resource ?loc - location)
        :precondition (and (at ?rover ?loc) 
                           (explored ?loc) 
                           (resource_at ?res ?loc) )
        :effect (and (collected ?res)
                     (not(resource_at ?res ?loc))
                     (increase (total-cost) 1)
                )
    )
    
    ;; Recharge energy action
    (:action recharge
        :parameters (?agent - agent ?loc - base)
        :precondition (and (at ?agent ?loc) (charging_station ?loc))
        :effect (and (assign (energy-level ?agent) 10)
                     (increase (total-cost) 5))
    )
)