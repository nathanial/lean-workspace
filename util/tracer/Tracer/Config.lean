/-
  Tracer.Config - Tracer configuration with builder pattern

  Configures service name, sampling, and export settings.
-/

import Tracer.Core.Span

namespace Tracer

/-- Sampler decides whether to sample based on trace context -/
structure Sampler where
  /-- Decide whether to sample based on trace context -/
  shouldSample : TraceContext → IO Bool
  deriving Inhabited

/-- Exporter sends spans to a backend -/
structure Exporter where
  /-- Export a batch of spans -/
  exportSpans : Array Span → IO Unit
  /-- Shutdown the exporter -/
  shutdown : IO Unit := pure ()
  deriving Inhabited

/-- Tracer configuration -/
structure TracerConfig where
  /-- Service name for this application -/
  serviceName : String
  /-- Sampler to determine which traces to record -/
  sampler : Sampler := { shouldSample := fun _ => pure true }
  /-- Exporters to send spans to -/
  exporters : Array Exporter := #[]
  /-- Default attributes added to all spans -/
  resourceAttributes : Array Attribute := #[]
  /-- Maximum number of attributes per span -/
  maxAttributes : Nat := 128
  /-- Maximum number of events per span -/
  maxEvents : Nat := 128
  /-- Batch size for export -/
  batchSize : Nat := 512
  deriving Inhabited

namespace TracerConfig

/-- Create a default configuration with service name -/
def default (serviceName : String) : TracerConfig :=
  { serviceName }

/-- Set the sampler -/
def withSampler (c : TracerConfig) (s : Sampler) : TracerConfig :=
  { c with sampler := s }

/-- Add an exporter -/
def withExporter (c : TracerConfig) (e : Exporter) : TracerConfig :=
  { c with exporters := c.exporters.push e }

/-- Set exporters (replaces existing) -/
def withExporters (c : TracerConfig) (es : Array Exporter) : TracerConfig :=
  { c with exporters := es }

/-- Add a resource attribute -/
def withResourceAttribute (c : TracerConfig) (a : Attribute) : TracerConfig :=
  { c with resourceAttributes := c.resourceAttributes.push a }

/-- Set resource attributes (replaces existing) -/
def withResourceAttributes (c : TracerConfig) (as : Array Attribute) : TracerConfig :=
  { c with resourceAttributes := as }

/-- Set the service version attribute -/
def withServiceVersion (c : TracerConfig) (version : String) : TracerConfig :=
  c.withResourceAttribute (.string "service.version" version)

/-- Set the deployment environment attribute -/
def withEnvironment (c : TracerConfig) (env : String) : TracerConfig :=
  c.withResourceAttribute (.string "deployment.environment" env)

/-- Set maximum attributes per span -/
def withMaxAttributes (c : TracerConfig) (n : Nat) : TracerConfig :=
  { c with maxAttributes := n }

/-- Set maximum events per span -/
def withMaxEvents (c : TracerConfig) (n : Nat) : TracerConfig :=
  { c with maxEvents := n }

/-- Set batch size for export -/
def withBatchSize (c : TracerConfig) (n : Nat) : TracerConfig :=
  { c with batchSize := n }

end TracerConfig
end Tracer
