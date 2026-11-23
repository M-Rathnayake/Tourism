export const SITE_NAME = "Ceylon Trails";
export const SITE_DESCRIPTION =
  "Tailored Sri Lanka journeys, ready-made tour packages, and private driver experiences.";
export const CONTACT = {
  email: "hello@ceylontrails.com",
  phone: "+94 77 000 0000",
  whatsapp: process.env.NEXT_PUBLIC_WHATSAPP_NUMBER ?? "94770000000",
  address: "Colombo, Sri Lanka",
};

export const NAV_LINKS = [
  { label: "Packages", href: "/packages" },
  { label: "Build Your Journey", href: "/journey" },
  { label: "About", href: "/about" },
  { label: "Contact", href: "/contact" },
] as const;
