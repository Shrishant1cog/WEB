import { Metadata } from "next";

export const metadata: Metadata = {
  title: "FFT - Free Fire Tournament Management Platform",
  description: "Organize and participate in Free Fire tournaments",
};

export default function PublicLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-white">
      {children}
    </div>
  );
}