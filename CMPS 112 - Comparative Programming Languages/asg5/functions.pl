
/* sub radians in haversine.pl Prolog v. */
dms_radian(degmin(Deg, Min), Result) :-
    Result is (Deg + Min / 60) * pi / 180.

/* Not in Prolog from graphpaths.pl.lis*/
not( X ) :- X, !, fail.
not( _ ).

/* Formula kindly given by Mackey */
haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
    dms_radian( Lat1, RLat1 ),
    dms_radian( Lon1, RLon1 ),
    dms_radian( Lat2, RLat2 ),
    dms_radian( Lon2, RLon2 ),
    DLon is RLon2 - RLon1,
    Dlat is RLat2 - RLat1,
    A is sin( Dlat / 2 ) ** 2
        + cos( RLat1 ) * cos( RLat2 ) * sin( DLon / 2 ) ** 2,
    Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
    Distance is Dist * 3961.

/* Time correction fn  when incorrect*/
evaluate_time( Hours, Minutes, ArriveHours, ArriveMinutes ) :-
    Minutes >= 60,
    ArriveHours is Hours + 1,
    ArriveMinutes is Minutes - 60.

/* Normal < 60 time */
evaluate_time( Hours, Minutes, ArriveHours, ArriveMinutes ) :-
    Minutes < 60,
    ArriveHours is Hours,
    ArriveMinutes is Minutes.

/* Converts Distance to Time between Airpots */
flight_time( GPort, MPort, FlightT ) :-
    airport( GPort, _, Lat1, Lon1 ),
    airport( MPort, _, Lat2, Lon2 ),
    /* Gets Distance */
    haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance),
    FlightT is Distance / 500.

/* Find Arrival Time between 2 Airports */
arrival_time( flight(GPort, MPort, time( DepHour,DepMin )), ATime) :-
    flight_time( GPort, MPort, FlightT ),
    DepartureTime is DepHour + DepMin / 60,
    ATime is DepartureTime + FlightT. %Hours

/* Conversion functions */
to_hours( Hours, Minutes, HourMinutes ) :-
    HourMinutes is Hours + Minutes / 60.

miles_to_hours(Miles, Hours) :-
    Hours is Miles / 500.

to_minutes( Hours, Minutes ) :-
    Minutes is Hours * 60.

/* Prints Time in Given Format*/
print_time( HoursMinutes ) :-
    Digits is floor(HoursMinutes * 60),
    Hours is Digits // 60,
    Minutes is Digits mod 60,
    format( '%2d:%2d', [Hours, Minutes]).

/* Writes Path */
writepath( [] ) :-
    nl.

writepath( [flight(Depart, Arrive, time(DepHour, DepMin))|Times]) :-
    airport( Depart, DepartName, _, _),
    airport( Arrive, ArriveName, _, _),
    to_hours( DepHour, DepMin, DepartTime ),
    /* calc arrival time using list */
    arrival_time( flight(Depart, Arrive, time(DepHour, DepMin)), ATime),
    format( 'depart   %s   %s', [Depart, DepartName]),
    print_time( DepartTime ), nl,
    format( 'arrive   %s   %s', [Arrive, ArriveName]),
    print_time( ATime ), nl,
    writepath( Times ).

/* Convert to support time format */
checktime( Hours1, time( TimeHours1, TimeMin1 )) :-
    to_hours( TimeHours1, TimeMin1, Hours2 ),
    to_minutes( Hours1, Mins1 ),
    to_minutes( Hours2, Mins2 ),
    Mins1 + 29 < Mins2.

checkarrival( flight( Dep,Arr,DepTime )) :-
   arrival_time( flight( Dep,Arr,DepTime ), ArriveTime ),
   ArriveTime < 24.

/* Generate path traversal list */
listpath( Node, End, [flight( Node, Next, NDep)|Outlist] ) :-
    not(Node = End),
    flight(Node, Next, NDep),
    listpath( Next, End, [flight( Node, Next, NDep)], Outlist ).
listpath( Node, Node, _, [] ).
listpath( Node, End,
    [flight( PDep, PArr, PDepTime )| Tried],
    [flight( Node, Next, NDep )| Times] ) :-
    flight( Node, Next, NDep),
    arrival_time( flight( PDep, PArr, PDepTime ), PArriv),
    checktime( PArriv, NDep ),
    checkarrival( flight( Node, Next, NDep )),
    Tried2 = append( [flight( PDep, PArr, PDepTime )], Tried ),
    not( member( Next, Tried2 )),
    not( Next = PArr ), 
    listpath( Next, End, 
    [flight( Node, Next, NDep )|Tried2], 
    Times ).

/* run query */
fly( Depart, Arrive ) :-
    listpath( Depart, Arrive, Times),
    !, nl,
    writepath(Times),
    true. 

fly( Depart, Depart ) :-
    write( 'Errors, the flight from ' ), write(Depart),
    write( ' to '), write(Depart), write( ' cannot happen' ),
    nl,
    !, fail.
