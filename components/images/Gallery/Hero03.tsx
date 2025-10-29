/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/hero-03.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Hero03({ alt, ...rest }: Props) {
  return <img src={String(src)} alt={alt ?? 'Hero 03'} loading="lazy" decoding="async" {...rest} />;
}
