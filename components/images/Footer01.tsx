/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/footer-01.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Footer01({ alt, ...rest }: Props) {
  return (
    <img src={String(src)} alt={alt ?? 'Footer 01'} loading="lazy" decoding="async" {...rest} />
  );
}
