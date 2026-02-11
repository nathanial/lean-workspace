/-
  Demo Runner - Canopy app NodeEditor tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos

private def roundTo (v : Float) (places : Nat) : Float :=
  let factor := (10 : Float) ^ places.toFloat
  (v * factor).round / factor

private def formatFloat (v : Float) (places : Nat := 1) : String :=
  let s := toString (roundTo v places)
  if s.any (· == '.') then
    let s := s.dropRightWhile (· == '0')
    if s.endsWith "." then s.dropRight 1 else s
  else
    s

private def port (label : String) (typeId : NodePortTypeId := NodePortTypeId.any)
    (color : Option Color := none) : NodePort :=
  { label, typeId, color }

private def comfyGraph : NodeEditorModel := {
  nodes := #[
    {
      title := "CheckpointLoaderSimple"
      subtitle := "model"
      position := Point.mk' 24 120
      width := 286
      accent := Color.fromRgb8 94 223 130
      outputs := #[
        port "MODEL" NodePortTypeId.model,
        port "CLIP" NodePortTypeId.clip,
        port "VAE" NodePortTypeId.vae
      ]
    },
    {
      title := "CLIPTextEncode"
      subtitle := "prompt"
      position := Point.mk' 372 26
      width := 368
      accent := Color.fromRgb8 142 199 255
      inputs := #[port "clip" NodePortTypeId.clip]
      outputs := #[port "CONDITIONING" NodePortTypeId.conditioning]
    },
    {
      title := "CLIPTextEncode"
      subtitle := "negative"
      position := Point.mk' 372 246
      width := 368
      accent := Color.fromRgb8 142 199 255
      inputs := #[port "clip" NodePortTypeId.clip]
      outputs := #[port "CONDITIONING" NodePortTypeId.conditioning]
    },
    {
      title := "KSampler"
      subtitle := "sampling"
      position := Point.mk' 804 138
      width := 314
      accent := Color.fromRgb8 175 191 255
      inputs := #[
        port "model" NodePortTypeId.model,
        port "positive" NodePortTypeId.conditioning,
        port "negative" NodePortTypeId.conditioning,
        port "latent_image" NodePortTypeId.latent
      ]
      outputs := #[port "LATENT" NodePortTypeId.latent]
    },
    {
      title := "VAEDecode"
      subtitle := "decode"
      position := Point.mk' 1182 202
      width := 220
      accent := Color.fromRgb8 245 197 94
      inputs := #[port "samples" NodePortTypeId.latent, port "vae" NodePortTypeId.vae]
      outputs := #[port "IMAGE" NodePortTypeId.image]
    },
    {
      title := "SaveImage"
      subtitle := "output"
      position := Point.mk' 1478 182
      width := 214
      accent := Color.fromRgb8 100 236 167
      inputs := #[port "images" NodePortTypeId.image]
    },
    {
      title := "LoadImage"
      subtitle := "inpaint"
      position := Point.mk' 46 462
      width := 330
      accent := Color.fromRgb8 120 211 250
      outputs := #[
        port "IMAGE" NodePortTypeId.image,
        port "MASK" NodePortTypeId.mask
      ]
    },
    {
      title := "VAEEncodeForInpaint"
      subtitle := "latent"
      position := Point.mk' 420 506
      width := 256
      accent := Color.fromRgb8 245 197 94
      inputs := #[
        port "pixels" NodePortTypeId.image,
        port "vae" NodePortTypeId.vae,
        port "mask" NodePortTypeId.mask
      ]
      outputs := #[port "LATENT" NodePortTypeId.latent]
    }
  ]
  connections := #[
    { fromNode := 0, fromOutput := 1, toNode := 1, toInput := 0 },
    { fromNode := 0, fromOutput := 1, toNode := 2, toInput := 0 },
    { fromNode := 0, fromOutput := 0, toNode := 3, toInput := 0 },
    { fromNode := 1, fromOutput := 0, toNode := 3, toInput := 1 },
    { fromNode := 2, fromOutput := 0, toNode := 3, toInput := 2 },
    { fromNode := 6, fromOutput := 0, toNode := 7, toInput := 0 },
    { fromNode := 0, fromOutput := 2, toNode := 7, toInput := 1 },
    { fromNode := 6, fromOutput := 1, toNode := 7, toInput := 2 },
    { fromNode := 7, fromOutput := 0, toNode := 3, toInput := 3 },
    { fromNode := 3, fromOutput := 0, toNode := 4, toInput := 0 },
    { fromNode := 0, fromOutput := 2, toNode := 4, toInput := 1 },
    { fromNode := 4, fromOutput := 0, toNode := 5, toInput := 0 }
  ]
}

private def nodeTitle (idx : Nat) : String :=
  match comfyGraph.nodes[idx]? with
  | some node => node.title
  | none => s!"node {idx}"

def nodeEditorTabContent (_env : DemoEnv) : WidgetM Unit := do
  let rootStyle : BoxStyle := {
    width := .percent 1.0
    height := .percent 1.0
    flexItem := some (FlexItem.growing 1)
  }

  column' (gap := 8) (style := rootStyle) do
    caption' "ComfyUI-style node graph demo. Drag from output dots to input dots to wire. Left-drag nodes, right/middle-drag empty canvas to pan, delete/backspace removes selected edge."

    let editor ← nodeEditor comfyGraph
      {
        width := 1720
        height := 900
        fillWidth := true
        fillHeight := true
        initialCamera := Point.mk' 18 8
        gridSize := 24
        majorGridEvery := 5
      }
      #[
        {
          nodeIdx := 3
          minHeight := 96
          content := do
            let seedInput ← textInput "seed" "1040111309094545"
            let _ ← dynWidget seedInput.text fun txt => do
              caption' s!"seed: {txt}"
            pure ()
        },
        {
          nodeIdx := 6
          minHeight := 72
          content := do
            let _ ← searchInput "filename" "yosemite_inpaint_example.png"
            pure ()
        }
      ]

    let _ ← dynWidget editor.selectedNode fun selected => do
      let selectedText :=
        match selected with
        | some idx => s!"Selected: {nodeTitle idx}"
        | none => "Selected: none"
      caption' selectedText

    let _ ← dynWidget editor.cameraOffset fun camera => do
      caption' s!"Camera: ({formatFloat camera.x}, {formatFloat camera.y})"

    pure ()

end Demos
