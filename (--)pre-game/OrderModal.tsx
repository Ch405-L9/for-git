import React from 'react'

type Props = { open:boolean, onClose:()=>void }

export default function OrderModal({ open, onClose }:Props){
  const [email, setEmail] = React.useState('')
  const [name, setName] = React.useState('')
  const [note, setNote] = React.useState('')

  if(!open) return null
  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-label="Order confirmation">
      <div className="modal">
        <header>Confirm Your Order</header>
        <p>This demo bypasses live payments. Confirm and we will send a summary with a link to complete via Toast if needed.</p>
        <label>
          Name
          <input
            value={name}
            onChange={e=>setName(e.target.value)}
            style={{display:'block',width:'100%',marginTop:4,marginBottom:8,padding:8}}
            aria-label="Name"
          />
        </label>
        <label>
          Email
          <input
            value={email}
            onChange={e=>setEmail(e.target.value)}
            style={{display:'block',width:'100%',marginTop:4,marginBottom:8,padding:8}}
            aria-label="Email"
          />
        </label>
        <label>
          Notes
          <textarea
            value={note}
            onChange={e=>setNote(e.target.value)}
            style={{display:'block',width:'100%',marginTop:4,marginBottom:8,padding:8,height:100}}
            aria-label="Notes"
          />
        </label>
        <div className="actions">
          <button className="button" onClick={onClose}>Cancel</button>
          <button
            className="button primary"
            onClick={()=>{
              // In production, send to backend to email confirmation or store lead.
              alert(`Confirmed for ${name || 'Guest'} — check ${email || 'your inbox'} for details.`)
              onClose()
            }}
          >
            Confirm
          </button>
        </div>
      </div>
    </div>
  )
}