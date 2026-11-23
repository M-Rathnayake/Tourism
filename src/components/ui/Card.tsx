import type { HTMLAttributes, ReactNode } from "react";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode;
}

export function Card({ children, className = "", ...props }: CardProps) {
  return (
    <div
      className={`rounded-2xl border border-tropical-900/10 bg-white p-5 shadow-soft sm:p-6 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}
