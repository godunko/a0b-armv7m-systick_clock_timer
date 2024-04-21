--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Restrictions (No_Elaboration_Code);

with A0B.ARMv7M.SysTick;

function A0B.Time.Clock return A0B.Time.Monotonic_Time is
begin
   return A0B.ARMv7M.SysTick.Clock;
end A0B.Time.Clock;