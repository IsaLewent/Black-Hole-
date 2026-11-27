import glsl from "vite-plugin-glsl";
import legacy from "@vitejs/plugin-legacy";
import { defineConfig } from "vite";

export default defineConfig({
  root: "src/",
  publicDir: "../public/",

  plugins: [
    glsl(),
    legacy({
      targets: ["defaults", "ios >= 13", "safari >= 13"],
      renderLegacyChunks: true,
    }),
  ],

  server: {
    host: true,
    port: 5173,
  },

  build: {
    outDir: "../dist",
    emptyOutDir: true,
    sourcemap: true,
  },
});