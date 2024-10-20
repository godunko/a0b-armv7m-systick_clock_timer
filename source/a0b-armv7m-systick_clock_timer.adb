--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Restrictions (No_Elaboration_Code);

pragma Ada_2022;

with A0B.ARMv7M.Instructions; use A0B.ARMv7M.Instructions;
with A0B.ARMv7M.SCS.SYST;     use A0B.ARMv7M.SCS.SYST;
with A0B.Timer.Internals;

package body A0B.ARMv7M.SysTick_Clock_Timer is

   procedure SysTick_Handler
     with Export, Convention => C, External_Name => "SysTick_Handler";
         --   Linker_Section => ".itcm.text";

   Tick_Frequency    : constant := 1_000;
   Tick_Duration     : constant := 1_000_000;
   --  Tick frequency in Hz and tick's duration in nanoseconds.

   Overflow_Counter  : A0B.Types.Unsigned_64 := 0;
   --    with Volatile, Linker_Section => ".dtcm.data";
   --  Counter of the SysTick timer overflows multiplied by 1_000, thus it is
   --  base monotonic time for current tick in microseconds.

   Millisecond_Ticks : A0B.Types.Unsigned_32;
   --    with Linker_Section => ".dtcm.data";
   Microsecond_Ticks : A0B.Types.Unsigned_32;
   --    with Linker_Section => ".dtcm.data";
   --  Number of the timer's ticks in one microsecond.

   -----------
   -- Clock --
   -----------

   function Clock return A0B.Time.Monotonic_Time is
      pragma Suppress (Division_Check);
      --  Suppress division by zero check, Microsecond_Ticks must not be equal
      --  to zero when configured properly.

      use type A0B.Types.Unsigned_64;

      Result       : A0B.Types.Unsigned_64;
      CURRENT      : A0B.Types.Unsigned_32;
      Microseconds : A0B.Types.Unsigned_32;

   begin
      --  SysTick timer interrupt has lowerst priority, thus can be handled
      --  only when there is no another higher priority tasks/interrupts.
      --  However, Clock subprogram can be called by the task with any
      --  priority, thus global Overflow_Count object might be not updated
      --  yet. So, it is updated here. Interrupts are disabled to make sure
      --  that no other higher priority task do update.

      Disable_Interrupts;

      Result  := Overflow_Counter;
      CURRENT := SYST_CVR.CURRENT;

      if SYST_CSR.COUNTFLAG then
         CURRENT          := SYST_CVR.CURRENT;
         --  Reload CURRENT because it might overflow after the first read
         --  operation.

         Result           := @ + Tick_Duration;
         Overflow_Counter := Result;
      end if;

      Enable_Interrupts;

      Microseconds := (Millisecond_Ticks - CURRENT) / Microsecond_Ticks;
      Result       := @ + A0B.Types.Unsigned_64 (Microseconds * 1_000);

      return A0B.Time.To_Monotonic_Time (Result);
   end Clock;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Use_Processor_Clock : Boolean;
      Clock_Frequency     : A0B.Types.Unsigned_32)
   is
      Reload_Value : A0B.Types.Unsigned_32;

   begin
      Millisecond_Ticks := Clock_Frequency / Tick_Frequency;
      Microsecond_Ticks := Millisecond_Ticks / 1_000;
      Reload_Value      := Millisecond_Ticks - 1;

      A0B.Timer.Internals.Initialize;

      SYST_RVR.RELOAD  := A0B.Types.Unsigned_24 (Reload_Value);
      SYST_CVR.CURRENT := 0;  --  Any write operation resets value to zero.
      SYST_CSR :=
        (ENABLE    => True,                 --  Enable timer
         TICKINT   => True,                 --  Enable interrupt
         CLKSOURCE => Use_Processor_Clock,  --  Use CPU clock
         others    => <>);
   end Initialize;

   ---------------------
   -- SysTick_Handler --
   ---------------------

   procedure SysTick_Handler is
      use type A0B.Types.Unsigned_64;

   begin
      --  SysTick handler has lowerst priority, thus can be preempted by any
      --  task/interrupt which can call Clock function. Disable interrupts
      --  till update of the overflow counter, and check whether overflow has
      --  been processed by higher priority task/interrupt before update of
      --  the counter.

      Disable_Interrupts;

      if SYST_CSR.COUNTFLAG then
         Overflow_Counter := @ + Tick_Duration;
      end if;

      Enable_Interrupts;

      A0B.Timer.Internals.On_Tick;
   end SysTick_Handler;

end A0B.ARMv7M.SysTick_Clock_Timer;
