import Crucible
import CrucibleTests.Fixtures
import CrucibleTests.PropertyTests

open Crucible

def main (args : List String) : IO UInt32 := runAllSuitesFiltered args
