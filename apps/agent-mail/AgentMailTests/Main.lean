/-
  Tests.Main - Test runner entry point
-/

import Crucible
import AgentMailTests.Types
import AgentMailTests.Project
import AgentMailTests.Agent
import AgentMailTests.Message
import AgentMailTests.FileReservation
import AgentMailTests.JsonRpc
import AgentMailTests.Config
import AgentMailTests.Database
import AgentMailTests.NameGenerator
import AgentMailTests.Identity
import AgentMailTests.DatabaseQueries
import AgentMailTests.Messaging
import AgentMailTests.ContactRequest
import AgentMailTests.Contact
import AgentMailTests.ContactDatabase
import AgentMailTests.ContactTools
import AgentMailTests.FileReservationDatabase
import AgentMailTests.FileReservationTools
import AgentMailTests.GitGuard
import AgentMailTests.GitGuardTools
import AgentMailTests.Search
import AgentMailTests.Macros
import AgentMailTests.BuildSlots
import AgentMailTests.Products
import AgentMailTests.Resources.Discovery
import AgentMailTests.Resources.Mail
import AgentMailTests.Resources.Threads
import AgentMailTests.Resources.Views
import AgentMailTests.Resources.FileReservations
import AgentMailTests.Middleware.Auth
import AgentMailTests.Middleware.RateLimit
import AgentMailTests.Middleware.CORS
import AgentMailTests.CLI.Commands

open Crucible

def main : IO UInt32 := runAllSuites
