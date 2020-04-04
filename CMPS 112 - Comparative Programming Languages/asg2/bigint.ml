(* $Id: bigint.ml,v 1.5 2014-11-11 15:06:24-08 - - $ *)
(* Names: Julius Fan (jzfan), Lucas Simon(lasimon) *)

open Printf

module Bigint = struct

    type sign     = Pos | Neg
    type bigint   = Bigint of sign * int list
    let  radix    = 10
    let  radixlen =  1

    let car       = List.hd
    let cdr       = List.tl
    let map       = List.map
    let reverse   = List.rev
    let strcat    = String.concat
    let strlen    = String.length
    let strsub    = String.sub
    let zero      = Bigint (Pos, [])

    let charlist_of_string str = 
        let last = strlen str - 1
        in  let rec charlist pos result =
            if pos < 0
            then result
            else charlist (pos - 1) (str.[pos] :: result)
        in  charlist last []

    let bigint_of_string str =
        let len = strlen str
        in  let to_intlist first =
                let substr = strsub str first (len - first) in
                let digit char = int_of_char char - int_of_char '0' in
                map digit (reverse (charlist_of_string substr))
            in  if   len = 0
                then zero
                else if   str.[0] = '_'
                     then Bigint (Neg, to_intlist 1)
                     else Bigint (Pos, to_intlist 0)

    let string_of_bigint (Bigint (sign, value)) =
        match value with
        | []    -> "0"
        | value -> let reversed = reverse value
                   in  strcat ""
                       ((if sign = Pos then "" else "-") ::
                        (map string_of_int reversed))

    let rec add' list1 list2 carry = match (list1, list2, carry) with
        | list1, [], 0       -> list1
        | [], list2, 0       -> list2
        | list1, [], carry   -> add' list1 [carry] 0
        | [], list2, carry   -> add' [carry] list2 0
        | car1::cdr1, car2::cdr2, carry ->
          let sum = car1 + car2 + carry
          in  sum mod radix :: add' cdr1 cdr2 (sum / radix)

    let rec sub' list1 list2 borrow = 
        match (list1, list2, borrow) with
        | [], [], 0           -> []
        | list1, [], 0        -> list1
        | list1, [], borrow   -> sub' list1 [borrow] 0
        | [], list2, 0        -> []
        | [], list2, borrow   -> []
        | car1::cdr1, car2::cdr2, borrow ->
            let sum = car1 - car2 - borrow
            in (sum + radix) mod radix :: sub' cdr1 cdr2 (if sum < 0 then 1 else 0)

    let get_rid_of_extra_zeros list = 
        let rec get_rid_of_extra_zeros' list' = match list' with
            | 0 :: cdr1         -> get_rid_of_extra_zeros' cdr1
            | _                 -> list'
        in reverse (get_rid_of_extra_zeros' (reverse list))

    let compare l1 l2 =
        let rec compare' list1 list2 who_bigger =
            match (list1, list2) with
            | [], []              -> who_bigger
            | list1, []           -> 1
            | [], list2           -> -1
            | car1::cdr1, car2::cdr2 ->
                if car1 = car2
                    then compare' cdr1 cdr2 who_bigger
                else if car1 > car2
                    then compare' cdr1 cdr2 1
                else
                    compare' cdr1 cdr2 (-1)
        in compare' (get_rid_of_extra_zeros l1) (get_rid_of_extra_zeros l2) 0

    let rec rem' dividend divisor =
        if compare dividend divisor = (-1)
            then dividend
        else
            let new_dividend = rem' dividend (add' divisor divisor 0)
            in
                if compare new_dividend divisor = (-1)
                    then new_dividend
                else
                    sub' new_dividend divisor 0


    let div' l1 l2 =
        let rec div'' dividend divisor num =
            if compare dividend divisor = (-1)
                then []
            else
                let new_dividend = rem' dividend (add' divisor divisor 0)
                in let total = div'' dividend (add' divisor divisor 0) (add' num num 0)
                in
                    if compare new_dividend divisor = (-1)
                        then total
                    else
                        (add' total num 0)                        

        in div'' l1 l2 [1]

    let rec multiply_up_to_ten list num =
        if num = 0
            then []
        else
            add' list (multiply_up_to_ten list (num - 1)) 0

    let rec add_zeroes list num =
        if num = 0
            then list
        else
            0 :: add_zeroes list (num - 1)

    let mul' l1 l2 =
        let rec mul'' list1 list2 zero_count =
            match (list1, list2) with
            | [], _                  -> []
            | _, []                  -> []
            | car1::cdr1, car2::cdr2 ->
                add' (add_zeroes (multiply_up_to_ten list1 car2) zero_count) (mul'' list1 cdr2 (zero_count + 1)) 0
        in mul'' l1 l2 0

    let rec pow' list1 list2 list3 = 
        let list4 = (get_rid_of_extra_zeros (sub' list2 [1] 0)) in
            if list4 = [] then list1
            else pow' (mul' list1 list3) list4 list3

    (* * * * * * * * * * * * *)

    let add (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        if neg1 = neg2
          then Bigint (neg1, add' value1 value2 0)
        else
          if compare value1 value2 = (-1)
            then Bigint (neg2, get_rid_of_extra_zeros (sub' value2 value1 0))
          else
            Bigint (neg1, get_rid_of_extra_zeros (sub' value1 value2 0))


    let sub (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        add (Bigint (neg1, value1)) (Bigint ((if neg2 = Pos then Neg else Pos), value2))

    let mul (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
         Bigint ((if neg1 = neg2 then Pos else Neg), mul' value1 value2)

    let div (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        Bigint ((if neg1 = neg2 then Pos else Neg), get_rid_of_extra_zeros (div' value1 value2))

    let rem (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        Bigint ((if neg1 = neg2 then Pos else Neg), get_rid_of_extra_zeros (rem' value1 value2))

    let pow (Bigint (neg1, list1)) (Bigint (neg2, list2)) =
        if neg2 = Neg then zero
        else match (list1, list2) with
            | [], list2      -> zero
            | list1, []      -> Bigint (Pos, [1])
            | list1, list2   -> Bigint (neg1, (get_rid_of_extra_zeros (pow' list1 list2 list1)))

end
