/* 
    IndiGolog - Mars Exploration
    This program models a Mars exploration mission where a rover and a drone work together
    to scan, explore areas and collect resources on Mars, while handling exogenous events such as
    sandstorms.
*/

cache(_) :- fail.

:- dynamic at/2, 
           energy_level/1, 
           scanned/1, 
           traversable/1, 
           explored/1,
           resource_at/2, 
           collected/1,
           adjacent/2, 
           sandstorm_at/1,
           controller/1.

:- discontiguous initially/1, 
                 initially/2, 
                 proc/2, 
                 proc/1, 
                 rel_fluent/1, 
                 fun_fluent/1, 
                 main/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/* FLUENTS */
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rel_fluent(at(_,_)).
rel_fluent(scanned(_)).
rel_fluent(traversable(_)).
rel_fluent(explored(_)).
rel_fluent(resource_at(_,_)).
rel_fluent(collected(_)).
rel_fluent(adjacent(_,_)).

rel_fluent(sandstorm_at(_)).

fun_fluent(energy_level(_)).

proc(enough_energy(Agent), energy_level(Agent) > 0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Domain Declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rover(rover1).
drone(drone1).
agent(Rover) :- rover(Rover).
agent(Drone) :- drone(Drone).

base(base1).
area(loc1).
area(loc2).
location(Base):- base(Base).
location(Area):- area(Area).

resource(res1).
resource(res2).
resource_at(Res, Loc):- resource(Res), area(Loc).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Primitive Actions and Preconditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Fly action
prim_action(fly(Drone, From, To)):-
    drone(Drone), location(From), area(To).
poss(fly(Drone, From, To), 
    and(at(Drone, From), and(adjacent(From, To), enough_energy(Drone)))).

% Scan action
prim_action(scan(Drone, Area)):-
    drone(Drone), area(Area).
poss(scan(Drone, Area), and(at(Drone, Area), enough_energy(Drone))).

% Move action
prim_action(move(Rover, From, To)):-
    rover(Rover), location(From), location(To).
poss(move(Rover, From, To), 
        and(at(Rover, From), and(adjacent(From, To), and(traversable(To), enough_energy(Rover))))).

% Explore action
prim_action(explore(Rover, Area)):-
    rover(Rover), area(Area).
poss(explore(Rover, Area), and(at(Rover, Area), and(traversable(Area), enough_energy(Rover)))).

% Collect action
prim_action(collect(Rover, Resource, Location)):-
    rover(Rover), resource(Resource), area(Location).
poss(collect(Rover, Resource, Location), 
    and(at(Rover, Location), and(resource_at(Resource, Location), 
    and(neg(collected(Resource)), and(explored(Location), enough_energy(Rover)))))).

% Handle Sandstorm action
prim_action(handle_sandstorm(Area)) :- area(Area).   
poss(handle_sandstorm(Area), sandstorm_at(Area)).    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sensing Actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Verify if there is no obstacle in the area
senses(detect_no_obstacle(Drone, Area), traversable(Area)).
prim_action(detect_no_obstacle(Drone, Area)):- drone(Drone), area(Area).
poss(detect_no_obstacle(Drone, Area), and(at(Drone, Area), scanned(Area))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Causal Laws
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

causes_false(fly(Drone,From,_To), at(Drone,From), true).
causes_true(fly(Drone,_From,To), at(Drone, To), true).
causes_val(fly(Drone,_From,_To), energy_level(Drone), E, E is energy_level(Drone)-1).

causes_true(scan(_Drone, Area), scanned(Area), true).
causes_val(scan(Drone, Area), energy_level(Drone), E, E is energy_level(Drone)-1).

causes_true(move(Rover,_From,To), at(Rover, To), true).
causes_false(move(Rover, From, _To), at(Rover, From), true).
causes_val(move(Rover,_From,_To), energy_level(Rover), E, E is energy_level(Rover)-1).

causes_true(explore(_Rover, Area), explored(Area), true).
causes_val(explore(Drone, Area), energy_level(Drone), E, E is energy_level(Drone)-1).

causes_true(collect(_Rover, Resource, _Location), collected(Resource), true).
causes_false(collect(_Rover, Resource, Location), resource_at(Resource, Location), true).
causes_val(collect(Rover, _Resource, _Location), energy_level(Rover), E, E is energy_level(Rover)-1).

causes_false(handle_sandstorm(Area), sandstorm_at(Area), true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exogenous Actions and Effects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exog_action(sandstorm(Area)):- area(Area).
causes_true(sandstorm(Area), sandstorm_at(Area), true).
causes_false(sandstorm(Area), scanned(Area), true).
causes_false(sandstorm(Area), traversable(Area), true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/* INITIAL SITUATION  */
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initially(at(rover1, base1), true).
initially(at(drone1, base1), true).

initially(scanned(base1), true).
initially(traversable(base1), true).
initially(explored(base1), true).

initially(resource_at(res1, loc1), true).
initially(resource_at(res2, loc2), true).

initially(energy_level(rover1), 10).
initially(energy_level(drone1), 10).

initially(adjacent(base1, loc1), true).
initially(adjacent(loc1, base1), true).
initially(adjacent(loc1, loc2), true).
initially(adjacent(loc2, loc1), true).

initialize :-
    forall(initially(Fact, true), assertz(Fact)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Procedures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(drone_scan_area(Drone, To), 
           [fly(Drone, From, To), scan(Drone, To), detect_no_obstacle(Drone, To)]).

proc(safe_move(Rover, To),
             [drone_scan_area(Drone, To), 
             if(traversable(To),
                move(Rover,From, To), [])]).

proc(explore_and_collect(Location, Resource), 
     [safe_move(Rover, Location),
      if(neg(explored(Location)), explore(Rover, Location), []),
      if(resource_at(Resource, Location), collect(Rover, Resource, Location), [])]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reasoning Tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Controller to collect a generic resource
proc(control(collect_resource), 
       if(some(r, neg(collected(r))), 
          pi([l,r], explore_and_collect(l,r)), 
          [])).

% Controller to collect all resources
proc(control(collect_all),
    while(some([r,l], (and(resource_at(r,l), neg(collected(r))))),
        [pi([l,r], explore_and_collect(l, r))])).

% Controller to collect all resources and handle exogenous events
proc(control(collect_all_exo),
     [prioritized_interrupts([
        interrupt(some(l, sandstorm_at(l)), pi(l, [handle_sandstorm(l), scan(Drone, l), detect_no_obstacle(Drone, l)])),
        interrupt(some([r,l], (and(resource_at(r,l), neg(collected(r))))), pi([l,r],explore_and_collect(l,r))),
        interrupt(true, ?(wait_exog_action))
        ])]).

actionNum(X,X).