/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/hero-05.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Hero05({ alt, ...rest }: Props) {
  return <img src={String(src)} alt={alt ?? 'Hero 05'} loading="lazy" decoding="async" {...rest} />;
}
