! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math strings help.markup help.syntax
calendar.backend math.order ;
IN: calendar

HELP: duration
{ $description "A duration is a period of time years, months, days, hours, minutes, and seconds.  All duration slots can store " { $link real } " numbers. Compare two timestamps with the " { $link <=> } " word." } ;

HELP: timestamp
{ $description "A timestamp is a date and a time with a timezone offset.  Timestamp slots must store integers except for " { $snippet "seconds" } ", which stores reals, and " { $snippet "gmt-offset" } ", which stores a " { $link duration } ". Compare two timestamps with the " { $link <=> } " word." } ;

{ timestamp duration } related-words

HELP: gmt-offset-duration
{ $values { "duration" duration } }
{ $description "Returns a " { $link duration } " object with the GMT offset returned by " { $link gmt-offset } "." } ;

HELP: <date>
{ $values { "year" integer } { "month" integer } { "day" integer } { "timestamp" timestamp } }
{ $description "Returns a timestamp object representing the start of the specified day in your current timezone." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "12 25 2010 <date> ."
                "T{ timestamp f 12 25 2010 0 0 0 T{ duration f 0 0 0 -5 0 0 } }"
    }
} ;

HELP: month-names
{ $values { "array" array } }
{ $description "Returns an array with the English names of all the months." }
{ $warning "Do not use this array for looking up a month name directly. Use month-name instead." } ;

HELP: month-name
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the month name and returns it as a string.  January has an index of 1 instead of zero." } ;

HELP: month-abbreviations
{ $values { "array" array } }
{ $description "Returns an array with the English abbreviated names of all the months." }
{ $warning "Do not use this array for looking up a month name directly. Use month-abbreviation instead." } ;

HELP: month-abbreviation
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the abbreviated month name and returns it as a string.  January has an index of 1 instead of zero." } ;


HELP: day-names
{ $values { "array" array } }
{ $description "Returns an array with the English names of the days of the week." } ;

HELP: day-name
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the day name and returns it as a string." } ;

HELP: day-abbreviations2
{ $values { "array" array } }
{ $description "Returns an array with the abbreviated English names of the days of the week.  This abbreviation is two characters long." } ;

HELP: day-abbreviation2
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the abbreviated day name and returns it as a string. This abbreviation is two characters long." } ;

HELP: day-abbreviations3
{ $values { "array" array } }
{ $description "Returns an array with the abbreviated English names of the days of the week.  This abbreviation is three characters long." } ;

HELP: day-abbreviation3
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the abbreviated day name and returns it as a string. This abbreviation is three characters long." } ;

{
    day-name day-names
    day-abbreviation2 day-abbreviations2
    day-abbreviation3 day-abbreviations3
} related-words

HELP: average-month
{ $values { "ratio" ratio } }
{ $description "The length of an average month averaged over 400 years. Used internally for adding an arbitrary real number of months to a timestamp." } ;

HELP: months-per-year
{ $values { "integer" integer } }
{ $description "Returns the number of months in a year." } ;

HELP: days-per-year
{ $values { "ratio" ratio } }
{ $description "Returns the number of days in a year averaged over 400 years. Used internally for adding an arbitrary real number of days to a timestamp." } ;

HELP: hours-per-year
{ $values { "ratio" ratio } }
{ $description "Returns the number of hours in a year averaged over 400 years. Used internally for adding an arbitrary real number of hours to a timestamp." } ;

HELP: minutes-per-year
{ $values { "ratio" ratio } }
{ $description "Returns the number of minutes in a year averaged over 400 years. Used internally for adding an arbitrary real number of minutes to a timestamp." } ;

HELP: seconds-per-year
{ $values { "integer" integer } }
{ $description "Returns the number of seconds in a year averaged over 400 years. Used internally for adding an arbitrary real number of seconds to a timestamp." } ;

HELP: julian-day-number
{ $values { "year" integer } { "month" integer } { "day" integer } { "n" integer } }
{ $description "Calculates the Julian day number from a year, month, and day.  The difference between two Julian day numbers is the number of days that have elapsed between the two corresponding dates." }
{ $warning "Not valid before year -4800 BCE." } ;

HELP: julian-day-number>date
{ $values { "n" integer } { "year" integer } { "month" integer } { "day" integer } }
{ $description "Converts from a Julian day number back to a year, month, and day." } ;
{ julian-day-number julian-day-number>date } related-words

HELP: >date<
{ $values { "timestamp" timestamp } { "year" integer } { "month" integer } { "day" integer } }
{ $description "Explodes a " { $snippet "timestamp" } " into its year, month, and day components." }
{ $examples { $example "USING: arrays calendar prettyprint ;"
                       "2010 8 24 <date> >date< 3array ."
                       "{ 2010 8 24 }"
                       }
} ;

HELP: >time<
{ $values { "timestamp" timestamp } { "hour" integer } { "minute" integer } { "second" integer } }
{ $description "Explodes a " { $snippet "timestamp" } " into its hour, minute, and second components." }
{ $examples { $example "USING: arrays calendar prettyprint ;"
                       "now noon >time< 3array ."
                       "{ 12 0 0 }"
                       }
} ;

{ >date< >time< } related-words

HELP: instant
{ $values { "duration" duration } }
{ $description "Pushes a " { $snippet "duration" } " of zero seconds." } ;

HELP: years
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: months
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: days
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: weeks
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: hours
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: minutes
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: seconds
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: milliseconds
{ $values { "x" number } { "duration" duration } }
{ $description } ;

HELP: leap-year?
{ $values { "obj" object } { "?" "a boolean" } }
{ $description "Returns " { $link t } " if the object represents a leap year." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "2008 leap-year? ."
               "t"
    }
    { $example "USING: calendar prettyprint ;"
               "2010 1 1 <date> leap-year? ."
               "f"
    }
} ;

HELP: time+
{ $values { "time1" "timestamp or duration" } { "time2" "timestamp or duration" } { "time3" "timestamp or duration" } }
{ $description "Adds two durations to produce a duration or adds a timestamp and a duration to produce a timestamp. The calculation takes timezones into account." }
{ $examples
    { $example "USING: calendar math.order prettyprint ;"
               "10 months 2 months time+ 1 years <=> ."
               "+eq+"
    }
    { $example "USING: accessors calendar math.order prettyprint ;"
               "2010 1 1 <date> 3 days time+ day>> ."
               "4"
    }
} ;

HELP: dt>years
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in years." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 months dt>years ."
               "1/2"
    }
} ;

HELP: dt>months
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in months." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "30 days dt>months ."
               "16000/16233"
    }
} ;

HELP: dt>days
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in days." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 hours dt>days ."
               "1/4"
    }
} ;

HELP: dt>hours
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in hours." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "3/4 days dt>hours ."
               "18"
    }
} ;
HELP: dt>minutes
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in minutes." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 hours dt>minutes ."
               "360"
    }
} ;
HELP: dt>seconds
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in seconds." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 minutes dt>seconds ."
               "360"
    }
} ;

HELP: dt>milliseconds
{ $values { "duration" duration } { "x" number } }
{ $description "Calculates the length of a duration in milliseconds." }
{ $examples
    { $example "USING: calendar prettyprint ;"
               "6 seconds dt>milliseconds ."
               "6000"
    }
} ;

{ dt>years dt>months dt>days dt>hours dt>minutes dt>seconds dt>milliseconds } related-words


HELP: time-
{ $values { "time1" "timestamp or duration" } { "time2" "timestamp or duration" } { "time3" "timestamp or duration" } }
{ $description "Subtracts two durations to produce a duration or subtracts a duration from a timestamp to produce a timestamp. The calculation takes timezones into account." }
{ $examples
    { $example "USING: calendar math.order prettyprint ;"
               "10 months 2 months time- 8 months <=> ."
               "+eq+"
    }
    { $example "USING: accessors calendar math.order prettyprint ;"
               "2010 1 1 <date> 3 days time- day>> ."
               "29"
    }
} ;

{ time+ time- } related-words

HELP: convert-timezone
{ $values { "timestamp" timestamp } { "duration" duration } { "timestamp" timestamp } }
{ $description "Converts the " { $snippet "timestamp" } "'s " { $snippet "gmt-offset" } " to the GMT offset represented by the " { $snippet "duration" } "." }
{ $examples
    { $example "USING: accessors calendar prettyprint ;"
               "gmt noon instant -5 >>hour convert-timezone gmt-offset>> hour>> ."
               "-5"
    }
} ;

HELP: >local-time
{ $values { "timestamp" timestamp } { "timestamp" timestamp } }
{ $description "Converts the " { $snippet "timestamp" } " to the timezone of your computer." }
{ $examples
    { $example "USING: accessors calendar kernel prettyprint ;"
               "now gmt >local-time [ gmt-offset>> ] bi@ = ."
               "t"
    }
} ;