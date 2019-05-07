defmodule Taysar.Routine do

  defstruct frolic:     false,
            grow:       false,
            tidy:       false,
            nothing:    false,
            exercise:   false,
            fuel:       false,
            groom:      false,
            calibrate:  false,
            strategize: false,
            connect:    false,
            learn:      false,
            create:     false,
            toil:       false,
            review:     false,
            simplify:   false,
            consume:    false,
            read:       false,
            sleep:      false

  def routine do
    [
      "Frolic",
      "Grow",
      "Tidy",
      "Nothing",
      "Exercise",
      "Fuel",
      "Groom",
      "Calibrate",
      "Strategize",
      "Connect",
      "Learn",
      "Create",
      "Toil",
      "Review",
      "Simplify",
      "Consume",
      "Read",
      "Sleep",
    ]
  end

end
