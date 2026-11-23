"use client";

import Link from "next/link";
import { Menu, X } from "lucide-react";
import { useState } from "react";
import { Container } from "@/components/ui/Container";
import { NAV_LINKS, SITE_NAME } from "@/config/constants";

export function Navbar() {
  const [open, setOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 border-b border-tropical-900/10 bg-cream/95 backdrop-blur">
      <Container className="flex h-16 items-center justify-between">
        <Link
          href="/"
          className="font-heading text-xl font-bold text-tropical-900"
          onClick={() => setOpen(false)}
        >
          {SITE_NAME}
        </Link>

        <nav className="hidden items-center gap-6 lg:flex" aria-label="Primary navigation">
          {NAV_LINKS.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="text-sm font-semibold text-tropical-900/75 transition hover:text-teal"
            >
              {item.label}
            </Link>
          ))}
          <Link
            href="/booking"
            className="inline-flex min-h-11 items-center rounded-full bg-gold px-5 py-2.5 text-sm font-bold text-tropical-900 transition hover:bg-[#c69b4e]"
          >
            Book Now
          </Link>
        </nav>

        <button
          type="button"
          className="grid h-11 w-11 place-items-center rounded-full text-tropical-900 lg:hidden"
          aria-label={open ? "Close navigation" : "Open navigation"}
          aria-expanded={open}
          onClick={() => setOpen((value) => !value)}
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </Container>

      {open ? (
        <nav
          className="border-t border-tropical-900/10 bg-cream px-4 pb-5 pt-3 lg:hidden"
          aria-label="Mobile navigation"
        >
          <div className="mx-auto flex max-w-7xl flex-col">
            {NAV_LINKS.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="border-b border-tropical-900/5 py-3 text-sm font-semibold"
                onClick={() => setOpen(false)}
              >
                {item.label}
              </Link>
            ))}
            <Link
              href="/booking"
              className="mt-4 inline-flex min-h-11 items-center justify-center rounded-full bg-gold px-5 py-2.5 text-sm font-bold text-tropical-900"
              onClick={() => setOpen(false)}
            >
              Book Now
            </Link>
          </div>
        </nav>
      ) : null}
    </header>
  );
}
