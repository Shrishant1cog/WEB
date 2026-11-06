import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Authentication - FFT",
  description: "Sign in or create an account for FFT Tournament Management",
};

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-gray-50">
      {children}
    </div>
  );
}