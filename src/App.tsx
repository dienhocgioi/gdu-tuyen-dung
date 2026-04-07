import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { ThemeProvider } from 'next-themes'

function App() {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      <Router>
        <Routes>
          <Route path="/" element={<div className="flex items-center justify-center min-h-screen">Loading...</div>} />
        </Routes>
      </Router>
    </ThemeProvider>
  )
}

export default App
