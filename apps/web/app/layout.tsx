import type { ReactNode } from "react";

export const metadata = {
  title: "Generador de Presupuestos",
  description: "Base reutilizable para presupuestos"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="es">
      <body style={{ margin: 0, fontFamily: "system-ui, sans-serif" }}>
        {children}
      </body>
    </html>
  );
}
