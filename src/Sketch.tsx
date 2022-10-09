import { useFrame, useThree } from "@react-three/fiber"
import { useMemo, useRef } from "react"
import fragment from "./shaders/fragment.glsl"
import vertex from "./shaders/vertex.glsl"
import * as THREE from "three"
import { useTexture } from "@react-three/drei"

const Sketch = () => {
  const { viewport } = useThree()

  const texture = useTexture("./matcap.png")

  return (
    <mesh>
      <planeGeometry args={[viewport.width, viewport.height]} />
      <RaymarchMaterial {...viewport} texture={texture} />
    </mesh>
  )
}

const positions = [
  new THREE.Vector3(1, 1, 4),
  new THREE.Vector3(0, -1, 4),
  new THREE.Vector3(1, -1.2, 4),
  new THREE.Vector3(0, -3.0, 4),
  new THREE.Vector3(-1, -1, 4),
  new THREE.Vector3(-1, 1.8, 4.5),
  new THREE.Vector3(0.5, 2.5, 4),
]

const r = [1.0, 0.5, 0.8, 1.2, 0.5, 0.8, 0.4]

const motion = [0.5, 3.0, 0.2, 0.1, 0.1, 0.4, 0.1]

const RaymarchMaterial = ({ width, height, texture }: any) => {
  const ref = useRef<THREE.ShaderMaterial>(null!)

  useFrame(
    ({ clock }) => (ref.current.uniforms.uTime.value = clock.getElapsedTime())
  )

  const uniforms = useMemo(
    () => ({
      resolution: {
        value: new THREE.Vector4(width, height, width / height, 1),
      },
      uTime: { value: 0 },
      uTexture: { value: texture },
      uPositions: { value: positions },
      uRadius: { value: r },
      uMotion: { value: motion },
    }),
    [width, height, texture]
  )

  return (
    <shaderMaterial
      ref={ref}
      uniforms={uniforms}
      vertexShader={vertex}
      fragmentShader={fragment}
    />
  )
}

export default Sketch
