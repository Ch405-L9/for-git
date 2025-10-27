import React from 'react'

type Props = { src:string }

export default function ToastEmbed({ src }:Props){
  return (
    <div className="card" role="region" aria-label="Toast ordering">
      <iframe
        title="Toast Online Ordering"
        src={src}
        style={{width:'100%',height:480,border:'1px solid rgba(0,0,0,.08)',borderRadius:'10px'}}
        loading="lazy"
      />
      <p style={{marginTop:8}}>
        Having trouble? <a href={src} target="_blank" rel="noreferrer">Open in a new tab</a>.
      </p>
    </div>
  )
}