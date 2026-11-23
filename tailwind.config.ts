import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/features/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        tropical: {
          50: "#edf7f1",
          100: "#d6eadd",
          500: "#1f6b45",
          700: "#174d34",
          900: "#103728",
        },
        teal: "#168c88",
        gold: "#d5ad63",
        sand: "#f3ead6",
        cream: "#fffdf7",
      },
      fontFamily: {
        heading: ["var(--font-playfair)", "Georgia", "serif"],
        sans: ["var(--font-inter)", "Arial", "sans-serif"],
      },
      boxShadow: {
        soft: "0 12px 40px rgba(16, 55, 40, 0.10)",
      },
    },
  },
  plugins: [],
};

export default config;
