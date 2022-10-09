import { useState } from "react"
import reactLogo from "./assets/react.svg"
import "./App.css"
import { Canvas } from "@react-three/fiber"
import Sketch from "./Sketch"
import { OrbitControls } from "@react-three/drei"

const App = () => (
  <Canvas>
    <Sketch />
  </Canvas>
)

export default App
