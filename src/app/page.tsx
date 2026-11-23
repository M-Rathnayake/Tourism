import { Container } from "@/components/ui/Container";
import { SectionTitle } from "@/components/ui/SectionTitle";
import { Card } from "@/components/ui/Card";

export default function HomePage() {
  return (
    <section className="py-16 sm:py-24">
      <Container>
        <SectionTitle
          eyebrow="Sri Lanka, thoughtfully explored"
          title="Your journey starts here"
          description="The foundation is ready. Packages, custom journeys, and secure booking experiences will be added step by step."
        />
        <Card className="mt-10 max-w-2xl">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-teal">
            Foundation confirmed
          </p>
          <p className="mt-3 text-tropical-900/70">
            This placeholder confirms the shared layout, typography, theme, and
            responsive container are working.
          </p>
        </Card>
      </Container>
    </section>
  );
}
