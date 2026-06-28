import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader.js';

// Helper to create a rounded plane geometry for screen bezels
function createRoundedPlaneGeometry(width, height, radius) {
  const shape = new THREE.Shape();
  const x = -width / 2;
  const y = -height / 2;
  
  shape.moveTo(x, y + radius);
  shape.lineTo(x, y + height - radius);
  shape.quadraticCurveTo(x, y + height, x + radius, y + height);
  shape.lineTo(x + width - radius, y + height);
  shape.quadraticCurveTo(x + width, y + height, x + width, y + height - radius);
  shape.lineTo(x + width, y + radius);
  shape.quadraticCurveTo(x + width, y, x + width - radius, y);
  shape.lineTo(x + radius, y);
  shape.quadraticCurveTo(x, y, x, y + radius);
  
  return new THREE.ShapeGeometry(shape);
}

function Phone3D({ markdown, theme }) {
  const containerRef = useRef(null);
  const textureCanvasRef = useRef(null);
  const sceneRef = useRef(null);
  const rendererRef = useRef(null);
  const phoneGroupRef = useRef(null);
  const textureRef = useRef(null);

  // Helper to draw the app screen onto a canvas that will act as the 3D texture
  const drawScreenTexture = () => {
    const canvas = textureCanvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const isDark = theme === 'dark';

    // Clear background
    ctx.fillStyle = isDark ? '#0b0f19' : '#ffffff';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Draw status bar
    ctx.fillStyle = isDark ? '#4f46e5' : '#e2e8f0';
    ctx.fillRect(0, 0, canvas.width, 45);
    ctx.fillStyle = isDark ? '#e0e7ff' : '#475569';
    ctx.font = 'bold 16px "DM Sans", sans-serif';
    ctx.fillText('10:42 AM', 20, 28);
    ctx.fillText('📶 🛜 🔋 100%', canvas.width - 130, 28);

    // Draw App Bar
    ctx.fillStyle = isDark ? '#6366f1' : '#f1f5f9';
    ctx.fillRect(0, 45, canvas.width, 65);
    
    // Back Arrow
    ctx.fillStyle = isDark ? '#ffffff' : '#0f172a';
    ctx.font = 'bold 22px sans-serif';
    ctx.fillText('←', 20, 85);
    
    // Filename
    ctx.font = 'bold 18px "DM Sans", sans-serif';
    ctx.fillText('nusta_demo.md', 60, 83);
    
    // Menu Dots
    ctx.fillText('⋮', canvas.width - 30, 83);

    // Divider line
    ctx.strokeStyle = isDark ? '#1e293b' : '#cbd5e1';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, 110);
    ctx.lineTo(canvas.width, 110);
    ctx.stroke();

    // Render markdown content inside the texture canvas
    const lines = markdown.split('\n');
    let y = 145;
    const paddingX = 25;
    let inCodeBlock = false;

    lines.forEach((line) => {
      const trimmed = line.trim();
      if (y > canvas.height - 40) return; // Cut off if overflow

      // Handle Code Block
      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        return;
      }

      if (inCodeBlock) {
        ctx.fillStyle = isDark ? '#0f172a' : '#f8fafc';
        ctx.fillRect(paddingX, y - 20, canvas.width - 2 * paddingX, 32);
        ctx.fillStyle = isDark ? '#06b6d4' : '#0891b2';
        ctx.font = '14px "JetBrains Mono", monospace';
        ctx.fillText(line, paddingX + 15, y);
        y += 35;
        return;
      }

      if (trimmed.startsWith('# ')) {
        ctx.fillStyle = isDark ? '#ffffff' : '#0f172a';
        ctx.font = 'bold 24px "Space Grotesk", sans-serif';
        ctx.fillText(trimmed.substring(2), paddingX, y);
        y += 40;
      } else if (trimmed.startsWith('## ')) {
        ctx.fillStyle = isDark ? '#ffffff' : '#0f172a';
        ctx.font = 'bold 20px "Space Grotesk", sans-serif';
        ctx.fillText(trimmed.substring(3), paddingX, y);
        y += 35;
      } else if (trimmed.startsWith('### ')) {
        ctx.fillStyle = isDark ? '#ffffff' : '#0f172a';
        ctx.font = 'bold 17px "Space Grotesk", sans-serif';
        ctx.fillText(trimmed.substring(4), paddingX, y);
        y += 30;
      } else if (trimmed.startsWith('- [x] ') || trimmed.startsWith('- [ ] ')) {
        const isChecked = trimmed.startsWith('- [x] ');
        // Draw checkbox
        ctx.strokeStyle = isDark ? '#06b6d4' : '#475569';
        ctx.lineWidth = 2;
        ctx.strokeRect(paddingX, y - 14, 16, 16);
        if (isChecked) {
          ctx.fillStyle = '#06b6d4';
          ctx.fillRect(paddingX + 3, y - 11, 10, 10);
        }
        
        ctx.fillStyle = isDark ? '#cbd5e1' : '#334155';
        ctx.font = '14px "DM Sans", sans-serif';
        ctx.fillText(trimmed.substring(6), paddingX + 25, y - 1);
        y += 28;
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        ctx.fillStyle = '#06b6d4';
        ctx.beginPath();
        ctx.arc(paddingX + 5, y - 5, 3, 0, Math.PI * 2);
        ctx.fill();

        ctx.fillStyle = isDark ? '#cbd5e1' : '#334155';
        ctx.font = '14px "DM Sans", sans-serif';
        ctx.fillText(trimmed.substring(2), paddingX + 20, y);
        y += 28;
      } else if (trimmed.startsWith('> ')) {
        ctx.fillStyle = '#06b6d4';
        ctx.fillRect(paddingX, y - 16, 4, 22);
        ctx.fillStyle = isDark ? '#94a3b8' : '#64748b';
        ctx.font = 'italic 14px "DM Sans", sans-serif';
        ctx.fillText(trimmed.substring(2), paddingX + 15, y);
        y += 30;
      } else if (trimmed === '') {
        y += 12;
      } else {
        ctx.fillStyle = isDark ? '#cbd5e1' : '#334155';
        ctx.font = '14px "DM Sans", sans-serif';
        
        // Clean bold formatting markers in canvas preview
        let cleanText = trimmed.replace(/\*\*(.*?)\*\*/g, '$1').replace(/`(.*?)`/g, '$1');
        ctx.fillText(cleanText, paddingX, y);
        y += 26;
      }
    });

    if (textureRef.current) {
      textureRef.current.needsUpdate = true;
    }
  };

  // Re-draw screen texture on content or theme changes
  useEffect(() => {
    drawScreenTexture();
  }, [markdown, theme]);

  // Main ThreeJS Setup
  useEffect(() => {
    if (!containerRef.current) return;

    // Clean up any previously attached canvases to prevent duplicate renders in development HMR / StrictMode
    containerRef.current.innerHTML = '';

    const width = containerRef.current.clientWidth || 350;
    const height = containerRef.current.clientHeight || 450;

    // Create scene
    const scene = new THREE.Scene();
    sceneRef.current = scene;

    // Camera setup
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
    camera.position.set(0, 0, 8);

    // Renderer setup
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    containerRef.current.appendChild(renderer.domElement);
    rendererRef.current = renderer;

    // Lights
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
    scene.add(ambientLight);

    const dirLight1 = new THREE.DirectionalLight(0xffffff, 1.2);
    dirLight1.position.set(5, 5, 5);
    scene.add(dirLight1);

    const dirLight2 = new THREE.DirectionalLight(0x6366f1, 0.8); // Indigo reflection
    dirLight2.position.set(-5, -3, 3);
    scene.add(dirLight2);

    const pointLight = new THREE.PointLight(0x06b6d4, 1.0, 10); // Cyan glow
    pointLight.position.set(0, 0, 2);
    scene.add(pointLight);

    // Create Phone Group
    const phoneGroup = new THREE.Group();
    scene.add(phoneGroup);
    phoneGroupRef.current = phoneGroup;

    // 1. Phone outer chassis (rounded box equivalent)
    const bodyGeom = new THREE.BoxGeometry(2.3, 4.6, 0.12);
    const bodyMat = new THREE.MeshStandardMaterial({
      color: theme === 'dark' ? 0x111827 : 0xf1f5f9,
      metalness: 0.9,
      roughness: 0.2,
      bumpScale: 0.05
    });
    const phoneChassis = new THREE.Mesh(bodyGeom, bodyMat);
    phoneGroup.add(phoneChassis);

    // 2. Bezel borders
    const borderGeom = new THREE.BoxGeometry(2.36, 4.66, 0.09);
    const borderMat = new THREE.MeshStandardMaterial({
      color: 0x1e293b,
      metalness: 0.95,
      roughness: 0.1
    });
    const phoneBorder = new THREE.Mesh(borderGeom, borderMat);
    phoneGroup.add(phoneBorder);

    // 3. Screen Plane (with rounded corners)
    const textureCanvas = document.createElement('canvas');
    textureCanvas.width = 380;
    textureCanvas.height = 760;
    textureCanvasRef.current = textureCanvas;
    
    // Initial draw
    drawScreenTexture();

    const canvasTexture = new THREE.CanvasTexture(textureCanvas);
    canvasTexture.minFilter = THREE.LinearFilter;
    canvasTexture.generateMipmaps = false;
    textureRef.current = canvasTexture;

    const screenGeom = createRoundedPlaneGeometry(2.15, 4.45, 0.2);
    const screenMat = new THREE.MeshStandardMaterial({
      map: canvasTexture,
      roughness: 0.15,
      metalness: 0.1
    });
    const screenMesh = new THREE.Mesh(screenGeom, screenMat);
    screenMesh.position.z = 0.062; // Place slightly on top of chassis front face
    phoneGroup.add(screenMesh);

    // 4. Camera bump on back
    const camGeom = new THREE.BoxGeometry(0.6, 0.6, 0.04);
    const camMat = new THREE.MeshStandardMaterial({ color: 0x0f172a, roughness: 0.4 });
    const camMesh = new THREE.Mesh(camGeom, camMat);
    camMesh.position.set(0.6, 1.8, -0.065);
    phoneGroup.add(camMesh);

    // Parallax interactive hover tracking
    let targetRotationX = 0;
    let targetRotationY = 0;
    let mouseX = 0;
    let mouseY = 0;

    const handleMouseMove = (event) => {
      const rect = renderer.domElement.getBoundingClientRect();
      // Normalized coordinates (-1 to +1)
      mouseX = ((event.clientX - rect.left) / rect.width) * 2 - 1;
      mouseY = -((event.clientY - rect.top) / event.height) * 2 + 1;
      
      targetRotationY = mouseX * 0.4;
      targetRotationX = -mouseY * 0.3;
    };

    const handleMouseLeave = () => {
      targetRotationX = 0;
      targetRotationY = 0;
    };

    const domElement = renderer.domElement;
    domElement.addEventListener('mousemove', handleMouseMove);
    domElement.addEventListener('mouseleave', handleMouseLeave);

    // Render loop
    let reqId;

    const animate = () => {
      reqId = requestAnimationFrame(animate);

      const elapsedTime = performance.now() * 0.001;

      // Slow passive rotation when no mouse interaction is happening
      if (targetRotationX === 0 && targetRotationY === 0) {
        phoneGroup.rotation.y = Math.sin(elapsedTime * 0.8) * 0.25;
        phoneGroup.rotation.x = Math.sin(elapsedTime * 0.4) * 0.08;
      } else {
        // Interpolate/smooth to mouse target
        phoneGroup.rotation.y += (targetRotationY - phoneGroup.rotation.y) * 0.08;
        phoneGroup.rotation.x += (targetRotationX - phoneGroup.rotation.x) * 0.08;
      }

      renderer.render(scene, camera);
    };

    animate();

    // ResizeObserver setup for precise parent dimensions
    const resizeObserver = new ResizeObserver((entries) => {
      for (let entry of entries) {
        const { width, height } = entry.contentRect;
        if (width && height) {
          camera.aspect = width / height;
          camera.updateProjectionMatrix();
          renderer.setSize(width, height);
        }
      }
    });
    resizeObserver.observe(containerRef.current);

    // Clean up
    return () => {
      cancelAnimationFrame(reqId);
      resizeObserver.disconnect();
      if (domElement) {
        domElement.removeEventListener('mousemove', handleMouseMove);
        domElement.removeEventListener('mouseleave', handleMouseLeave);
      }
      
      // Dispose elements
      bodyGeom.dispose();
      bodyMat.dispose();
      borderGeom.dispose();
      borderMat.dispose();
      screenGeom.dispose();
      screenMat.dispose();
      camGeom.dispose();
      camMat.dispose();
      canvasTexture.dispose();
      renderer.dispose();
      
      if (containerRef.current) {
        containerRef.current.innerHTML = '';
      }
    };
  }, [theme]); // Redo scene on theme change to swap phone body chassis materials

  return (
    <div 
      ref={containerRef} 
      className="w-full h-[45vh] min-h-[300px] max-h-[480px] flex items-center justify-center relative cursor-grab active:cursor-grabbing"
    />
  );
}

export default Phone3D;
