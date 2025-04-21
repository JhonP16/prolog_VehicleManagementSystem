% ------------------------------------------------------------------
% Catálogo de vehículos
% vehicle(Marca, Referencia, Tipo, Precio, Año).
% ------------------------------------------------------------------

vehicle(toyota, camry, sedan, 22000, 2020).
vehicle(toyota, rav4, suv, 28000, 2022).
vehicle(toyota, corolla, sedan, 18000, 2021).
vehicle(toyota, rav6, suv, 25000, 2024).

vehicle(ford, mustang, sport, 45000, 2023).
vehicle(ford, explorer, suv, 35000, 2021).
vehicle(ford, f150, pickup, 31000, 2020).

vehicle(bmw, x5, suv, 60000, 2021).
vehicle(bmw, serie3, sedan, 38000, 2020).

vehicle(nissan, frontier, pickup, 30000, 2020).

vehicle(honda, accord, sedan, 25000, 2019).

vehicle(chevrolet, silverado, pickup, 40000, 2022).

% ------------------------------------------------------------------
% Filtrado por presupuesto individual
% ------------------------------------------------------------------

meet_budget(Reference, BudgetMax) :-
    vehicle(_, Reference, _, Price, _),
    Price =< BudgetMax.

% ------------------------------------------------------------------
% Agrupación por marca
% ------------------------------------------------------------------

vehicles_by_brand(Brand, References) :-
    findall(Reference, vehicle(Brand, Reference, _, _, _), References).

% ------------------------------------------------------------------
% Reporte por marca, tipo y presupuesto individual
% ------------------------------------------------------------------

max_inventory(1000000).

compare_price(Order, vehicle(_, _, _, Price1, _), vehicle(_, _, _, Price2, _)) :-
    ( Price1 < Price2 -> Order = '<'
    ; Price1 > Price2 -> Order = '>'
    ; Order = '='
    ).

select_vehicles([], _, [], 0).
select_vehicles([vehicle(B, Ref, T, Price, Y)|Rest], Limit, [vehicle(B, Ref, T, Price, Y)|Selected], Total) :-
    Price =< Limit,
    NewLimit is Limit - Price,
    select_vehicles(Rest, NewLimit, Selected, SubTotal),
    Total is Price + SubTotal.
select_vehicles([_|Rest], Limit, Selected, Total) :-
    select_vehicles(Rest, Limit, Selected, Total).

generate_report(Brand, Type, PresupuestoInd, report(Vehiculos, TotalValor)) :-
    findall(vehicle(Brand, Ref, Type, Price, Y),
            (vehicle(Brand, Ref, Type, Price, Y),
             Price =< PresupuestoInd),
            RawList),
    predsort(compare_price, RawList, SortedList),
    max_inventory(LimInv),
    select_vehicles(SortedList, LimInv, Vehiculos, TotalValor).

generate_report_by_type(Type, Limite, report(Vehiculos, TotalValor)) :-
    findall(vehicle(Brand, Ref, Type, Price, Y),
            vehicle(Brand, Ref, Type, Price, Y),
            RawList),
    predsort(compare_price, RawList, SortedList),
    select_vehicles(SortedList, Limite, Vehiculos, TotalValor).

% ------------------------------------------------------------------
% Agrupación por marca, tipo y año usando bagof/3
% Ej: group_by_type_and_year(ford, Resultado).
% Resultado = [((sport, 2023), [mustang]), ((suv, 2021), [explorer]), ...]
% ------------------------------------------------------------------

group_by_type_and_year(Brand, ListaAgrupada) :-
    findall((Type, Year, Refs),
            bagof(Ref, vehicle(Brand, Ref, Type, _, Year), Refs),
            Triples),
    convert_to_pairs(Triples, ListaAgrupada).

convert_to_pairs([], []).
convert_to_pairs([(T, Y, R)|Rest], [((T, Y), R)|Converted]) :-
    convert_to_pairs(Rest, Converted).

% ------------------------------------------------------------------
% Casos de prueba
% ------------------------------------------------------------------

% Caso 1:
% ?- findall(Ref, (vehicle(toyota, Ref, suv, Price, _), Price < 30000), Refs).

% Caso 2:
% ?- group_by_type_and_year(ford, Resultado).

% Caso 3:
% ?- generate_report_by_type(sedan, 500000, Reporte).
