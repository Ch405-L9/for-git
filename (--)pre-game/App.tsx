import React from 'react'
import ToastEmbed from './components/ToastEmbed'
import OrderModal from './components/OrderModal'

export default function App(){
  const [open, setOpen] = React.useState(false)
  return (
    <div>
      <header className="header">
        <h1>Vinal Bakery</h1>
        <nav>
          <a href="#order" className="button primary" onClick={(e)=>{e.preventDefault();setOpen(true)}}>
            Order Now
          </a>
          <a href="#gift" className="button secondary" style={{marginLeft:12}}>Gift Cards</a>
        </nav>
      </header>

      <main style={{padding:'1rem'}}>
        <section className="card" style={{margin:'1rem 0'}}>
          <h2>Pickup & Delivery</h2>
          <p>Order breakfast classics, pastries, and coffee.</p>
          <ToastEmbed src="https://order.toasttab.com/online/vinal-bakery" />
        </section>

        <section className="card" style={{margin:'1rem 0'}}>
          <h2>Our Story</h2>
          <p>Union Square roots with New England ingredients, baked fresh daily.</p>
        </section>
      </main>

      <footer>
        <small>Ordering provided via Toast. Payments bypassed in this demo; confirmation modal only.</small>
      </footer>

      <OrderModal open={open} onClose={()=>setOpen(false)} />
    </div>
  )
}