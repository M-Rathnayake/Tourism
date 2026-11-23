import Link from "next/link";
import { Container } from "@/components/ui/Container";
import { CONTACT, NAV_LINKS, SITE_NAME } from "@/config/constants";

export function Footer() {
  return (
    <footer className="border-t border-tropical-900/10 bg-tropical-900 py-12 text-white">
      <Container className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
        <div>
          <p className="font-heading text-2xl font-bold">{SITE_NAME}</p>
          <p className="mt-3 max-w-sm text-sm leading-6 text-white/70">
            Tailored private journeys across Sri Lanka.
          </p>
        </div>
        <nav className="grid gap-2" aria-label="Footer navigation">
          {NAV_LINKS.map((item) => (
            <Link key={item.href} href={item.href} className="text-sm text-white/80 hover:text-gold">
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="text-sm text-white/80">
          <a className="block hover:text-gold" href={`mailto:${CONTACT.email}`}>
            {CONTACT.email}
          </a>
          <a className="mt-2 block hover:text-gold" href={`tel:${CONTACT.phone.replace(/\s/g, "")}`}>
            {CONTACT.phone}
          </a>
          <p className="mt-2">{CONTACT.address}</p>
        </div>
      </Container>
    </footer>
  );
}
