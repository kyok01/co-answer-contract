import '../styles/globals.css'
import type { AppProps } from 'next/app'
import { Suspense } from 'react'
import { Flowbite, Spinner } from 'flowbite-react'
import { flowbiteTheme as theme } from "../styles/theme";

function MyApp({ Component, pageProps }: AppProps) {
  return <Suspense
  fallback={
    <div className="flex items-center justify-center">
      <Spinner size="lg" /> Loading..
    </div>
  }
>
  <Flowbite theme={{ theme }}>
    <Component {...pageProps} />
  </Flowbite>
</Suspense>
}

export default MyApp
